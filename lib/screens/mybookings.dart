import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookings extends StatefulWidget {
  @override
  _MyBookingsState createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String? userEmail = _auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No bookings found",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.network(
                        booking['hotelImage'], // Strictly using given key names
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['hotelName'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text("Booked by: ${booking['fullName']}"),
                          SizedBox(height: 5),
                          Text("Available Rooms: ${booking['availableRooms']}"),
                          SizedBox(height: 5),
                          Text("Facilities: ${booking['facilities']}"),
                          SizedBox(height: 5),
                          Text("Description: ${booking['description']}"),
                          SizedBox(height: 5),
                          Text("Price Range: ${booking['priceRange']}"),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _confirmCancelBooking(booking.id),
                              icon: Icon(Icons.cancel, color: Colors.red),
                              label: Text("Cancel Booking",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmCancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Booking"),
        content: Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Yes, Cancel"),
            onPressed: () {
              _cancelBooking(bookingId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Booking canceled successfully")),
    );
  }
}
