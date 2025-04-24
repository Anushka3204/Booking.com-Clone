import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const BookingFormScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  _BookingFormScreenState createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _nameController = TextEditingController();
  final _roomsController = TextEditingController();
  final _membersController = TextEditingController();

  String _userEmail = '';
  bool _isLoading = false;
  bool _isEstimateComputed = false;
  int _estimatedPrice = 0;
  String _selectedRoomType = 'Standard';
  late Razorpay _razorpay;

  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  final List<String> _roomTypes = ['Standard', 'Deluxe', 'Suite'];

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() => _userEmail = user?.email ?? 'No email found');
  }

  Future<void> _selectCheckInDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? today,
      firstDate: today,
      lastDate: today.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // reset checkout if before new checkin
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      _showSnack("Select check‑in date first");
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? _checkInDate!.add(Duration(days: 1)),
      firstDate: _checkInDate!.add(Duration(days: 1)),
      lastDate: _checkInDate!.add(Duration(days: 366)),
    );
    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  void _estimatePrice() {
    final name = _nameController.text.trim();
    final rooms = int.tryParse(_roomsController.text) ?? 0;
    final members = int.tryParse(_membersController.text) ?? 0;

    if (name.isEmpty) {
      _showSnack("Please enter your full name");
      return;
    }
    if (_checkInDate == null || _checkOutDate == null) {
      _showSnack("Select both check‑in and check‑out dates");
      return;
    }
    if (rooms <= 0) {
      _showSnack("Enter a valid number of rooms");
      return;
    }
    if (members <= 0) {
      _showSnack("Enter a valid number of members");
      return;
    }

    // parse priceRange, e.g. "2000-5000"
    final parts = (widget.hotel['priceRange'] as String).split('-');
    final minPrice = int.parse(parts[0].replaceAll(RegExp(r'[^0-9]'), ''));
    final maxPrice = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    final avgPrice = ((minPrice + maxPrice) / 2).round();

    setState(() {
      _estimatedPrice = avgPrice * rooms;
      _isEstimateComputed = true;
    });
  }

  Future<void> _confirmBooking() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Confirm Booking"),
        content: Text("Are you sure you want to confirm this booking?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
                Text("Proceed to pay", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              _openRazorpayCheckout();
            },
          ),
        ],
      ),
    );
  }

  void _openRazorpayCheckout() {
    if (_estimatedPrice <= 0) {
      _showSnack("Estimate the price first");
      return;
    }

    final options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // your Razorpay key
      'amount': _estimatedPrice * 100, // in paise
      'name': widget.hotel['name'],
      'description': '$_selectedRoomType × ${_roomsController.text} rooms\n'
          'From ${_formatDate(_checkInDate!)} to ${_formatDate(_checkOutDate!)}',
      'prefill': {'email': _userEmail},
      'theme': {'color': '#003580'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      _showSnack("Could not open payment gateway");
    }
  }

  String _formatDate(DateTime d) => "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}";

  void _handlePaymentSuccess(PaymentSuccessResponse resp) async {
    await _processBooking();
  }

  void _handlePaymentError(PaymentFailureResponse resp) {
    _showSnack("Payment failed. Please try again.");
  }

  void _handleExternalWallet(ExternalWalletResponse resp) {
    _showSnack("External Wallet: ${resp.walletName}");
  }

  Future<void> _processBooking() async {
    setState(() => _isLoading = true);

    await Future.delayed(Duration(seconds: 2));

    final bookingDetails = {
      'fullName': _nameController.text.trim(),
      'email': _userEmail,
      'hotelName': widget.hotel['name'],
      'hotelImage': widget.hotel['image'],
      'description': widget.hotel['description'],
      'facilities': widget.hotel['facilities'],
      'availableRooms': widget.hotel['availableRooms'],
      'priceRange': widget.hotel['priceRange'],
      'roomType': _selectedRoomType,
      'numRooms': int.parse(_roomsController.text),
      'numMembers': int.parse(_membersController.text),
      'checkInDate': _checkInDate,
      'checkOutDate': _checkOutDate,
      'amountPaid': _estimatedPrice,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('bookings').add(bookingDetails);

    setState(() => _isLoading = false);
    _showSuccessDialog();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Booking Confirmed!",
                style: TextStyle(color: Colors.green, fontSize: 18)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm Booking",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[900],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Hotel details...
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.hotel['image'],
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text(widget.hotel['name'],
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Description: ${widget.hotel['description']}",
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Facilities: ${widget.hotel['facilities']}",
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Rooms Available: ${widget.hotel['availableRooms']}",
              style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text("Price Range: ${widget.hotel['priceRange']}",
              style: TextStyle(fontSize: 16)),
          Divider(height: 32),

          // Booking form fields
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Full Name'),
          ),
          SizedBox(height: 16),

          // Check‑in date
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Check‑In Date',
              hintText: _checkInDate != null
                  ? _formatDate(_checkInDate!)
                  : 'Select date',
            ),
            onTap: _selectCheckInDate,
          ),
          SizedBox(height: 16),

          // Check‑out date
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Check‑Out Date',
              hintText: _checkOutDate != null
                  ? _formatDate(_checkOutDate!)
                  : 'Select date',
            ),
            onTap: _selectCheckOutDate,
          ),
          SizedBox(height: 16),

          TextField(
            controller: _roomsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'No. of Rooms'),
          ),
          SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedRoomType,
            decoration: InputDecoration(labelText: 'Type of Room'),
            items: _roomTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedRoomType = v!),
          ),
          SizedBox(height: 16),

          TextField(
            controller: _membersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'No. of Members'),
          ),
          SizedBox(height: 24),

          // OK → estimate
          ElevatedButton(
            onPressed: _isLoading ? null : _estimatePrice,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                Text('OK', style: TextStyle(fontSize: 18, color: Colors.white)),
          ),

          // Estimated & Confirm
          if (_isEstimateComputed) ...[
            SizedBox(height: 24),
            Text("Total Price: ₹ $_estimatedPrice",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Confirm Booking',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ]),
      ),
    );
  }
}
