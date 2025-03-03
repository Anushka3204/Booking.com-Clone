import 'dart:io'; // Import File class
import 'package:booking/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String email;
  late String _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserData();
    _imagePath = ''; // Default empty image path
  }

  // Fetch user data from Firebase Auth
  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? 'Not available';
      });
    }
  }

  // Function to pick and upload the profile image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  // Extract initial from email
  String _getInitial() {
    return email.isNotEmpty ? email[0].toUpperCase() : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue[900], // Booking.com blue color
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage, // Allow image upload by tapping the avatar
                child: Container(
                  padding: EdgeInsets.all(5), // Space for the border
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.orange, width: 4), // Orange border
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue[900],
                    backgroundImage: _imagePath.isNotEmpty
                        ? FileImage(File(_imagePath))
                        : null,
                    child: _imagePath.isEmpty
                        ? Text(
                            _getInitial(), // Show initial if no image is available
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Email Card for better UI
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  child: Text(
                    email,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Logout Button
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Logout', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 20),

              // Option Buttons Below the Profile
              _buildOption("Forgot Password?", Icons.lock, () {
                // Implement forgot password logic here
              }),
              _buildOption("Edit Profile", Icons.edit, () {
                // Implement edit profile logic here
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method to build option buttons
  Widget _buildOption(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF0066cc), size: 22),
            SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF0066cc),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
