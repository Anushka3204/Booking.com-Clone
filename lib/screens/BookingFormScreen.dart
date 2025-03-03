import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const BookingFormScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  _BookingFormScreenState createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _nameController = TextEditingController();
  String _userEmail = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email ?? 'No email found';
    });
  }

  Future<void> _confirmBooking() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: Text("Confirm Booking"),
        content: Text("Are you sure you want to confirm this booking?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text("Confirm", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.pop(context); // Close the confirmation dialog
              await _processBooking();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 2)); // Simulating processing time

    // Prepare booking details
    Map<String, dynamic> bookingDetails = {
      'fullName': _nameController.text,
      'email': _userEmail,
      'hotelName': widget.hotel['name'],
      'hotelImage': widget.hotel['image'],
      'description': widget.hotel['description'],
      'facilities': widget.hotel['facilities'],
      'availableRooms': widget.hotel['availableRooms'],
      'priceRange': widget.hotel['priceRange'],
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Store booking in Firestore
    await FirebaseFirestore.instance.collection('bookings').add(bookingDetails);

    setState(() {
      _isLoading = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text(
              "Booking Confirmed!",
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Confirm Booking",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _userEmail),
              decoration: InputDecoration(labelText: 'Email'),
              style: TextStyle(fontSize: 16),
              enabled: false,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Confirm Booking', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
