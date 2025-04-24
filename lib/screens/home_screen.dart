// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'hotel_list_screen.dart'; // We'll create this next
import 'package:google_fonts/google_fonts.dart'; // For styling if needed
import 'hotel_list_screen.dart'; // New screen for listing hotels
import '../services/google_auth.dart'; // Ensure this exports FirebaseServices
import '../core/routes.dart'; // Assuming this has Routes.signIn
import 'ItineraryScreen.dart';
import 'profile.dart'; // Import your ProfileScreen here
import 'mybookings.dart';
import 'Favourites.dart';
import 'MovieMoodScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // Controller for the destination field
  final TextEditingController _destinationController = TextEditingController();
  String _selectedDateDisplay = "Select date";
  DateTimeRange? _selectedDateRange;

  // Variables for room details
  int _roomCount = 1;
  int _adultCount = 2;
  int _childrenCount = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedDateDisplay =
            "${DateFormat('E dd MMM').format(picked.start)} - ${DateFormat('E dd MMM').format(picked.end)}";
      });
    }
  }

  // Method to handle logout (for Google sign in)
  Future<void> _logout() async {
    await FirebaseServices().googleSignOut();
    Navigator.pushReplacementNamed(context, Routes.signIn);
  }

  Future<void> _selectRooms() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (BuildContext context) {
        // Temporary values for dialog
        int tempRoomCount = _roomCount;
        int tempAdultCount = _adultCount;
        int tempChildrenCount = _childrenCount;
        return AlertDialog(
          title: Text("Select Room Details"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text("Rooms: "),
                      DropdownButton<int>(
                        value: tempRoomCount,
                        items: List.generate(5, (index) => index + 1)
                            .map((value) => DropdownMenuItem(
                                  child: Text("$value"),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            tempRoomCount = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Adults: "),
                      DropdownButton<int>(
                        value: tempAdultCount,
                        items: List.generate(10, (index) => index + 1)
                            .map((value) => DropdownMenuItem(
                                  child: Text("$value"),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            tempAdultCount = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Children: "),
                      DropdownButton<int>(
                        value: tempChildrenCount,
                        items: List.generate(10, (index) => index)
                            .map((value) => DropdownMenuItem(
                                  child: Text("$value"),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            tempChildrenCount = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'rooms': tempRoomCount,
                  'adults': tempAdultCount,
                  'children': tempChildrenCount,
                });
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _roomCount = result['rooms']!;
        _adultCount = result['adults']!;
        _childrenCount = result['children']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          'Booking.com',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.explore, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ItineraryScreen()),
              );
            },
          ),

          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.movie_filter, color: Colors.white),
            tooltip: "Movie Mood Travel",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MovieMoodScreen()),
              );
            },
          ),

          // Logout Icon
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel, color: Colors.blue[900], size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Find your stays",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Search Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange, width: 2),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    _buildSearchField(
                      controller: _destinationController,
                      icon: Icons.search,
                      hintText: "Enter your destination",
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        color: Colors.white, // Background color
                        child: _buildSearchField(
                          icon: Icons.calendar_today,
                          hintText: _selectedDateDisplay,
                          isReadOnly: true,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectRooms,
                      child: Container(
                        color: Colors.white, // Background color
                        child: _buildSearchField(
                          icon: Icons.person,
                          hintText:
                              "${_roomCount} room · ${_adultCount} adults · ${_childrenCount} children",
                          isReadOnly: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 80),
                      ),
                      onPressed: () {
                        if (_destinationController.text.isEmpty ||
                            _selectedDateRange == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Please enter a destination and select dates")),
                          );
                          return;
                        }
                        String checkIn = DateFormat('yyyy-MM-dd')
                            .format(_selectedDateRange!.start);
                        String checkOut = DateFormat('yyyy-MM-dd')
                            .format(_selectedDateRange!.end);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelListScreen(
                              destination: _destinationController.text,
                              checkIn: checkIn,
                              checkOut: checkOut,
                              rooms:
                                  "$_roomCount", // passing room count as string
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Search",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Discount Section (example)
              Text(
                "Exclusive Discounts",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildDiscountCard(
                        "10% discounts on stays", "Enjoy discounts worldwide"),
                    _buildDiscountCard(
                        "10% off rental cars", "Save on select rental cars"),
                    _buildDiscountCard(
                        "Exclusive flight deals", "Best fares for members"),
                  ],
                ),
              ),
              SizedBox(height: 15),
              // Deals Section (example)
              Text(
                "Deals for the weekend",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "Save on stays for 31 January - 2 February",
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildDealCard(
                      "Paris, France",
                      "Starting from \$120/night",
                      "https://t3.ftcdn.net/jpg/02/09/70/56/360_F_209705645_b78HGJI1i1mxqLwMYA7z1m3VvCxgxJFO.jpg",
                    ),
                    _buildDealCard(
                      "New York, USA",
                      "Starting from \$150/night",
                      "https://thumbs.dreamstime.com/b/paris-eiffel-tower-river-seine-sunset-france-one-most-iconic-landmarks-107376702.jpg",
                    ),
                    _buildDealCard(
                      "Tokyo, Japan",
                      "Starting from \$130/night",
                      "https://media.istockphoto.com/id/484915982/photo/akihabara-tokyo.jpg?s=612x612&w=0&k=20&c=kbCRYJS5vZuF4jLB3y4-apNebcCEkWnDbKPpxXdf9Cg=",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar (example)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            // Navigate to Profile Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyFavourites()), // Navigate to Profile
            );
          }

          if (index == 2) {
            // Navigate to Profile Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyBookings()), // Navigate to Profile
            );
          }

          if (index == 3) {
            // Navigate to Profile Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfilePage()), // Navigate to Profile
            );
          }
        },
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 22), label: "Search"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 22), label: "Saved"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark, size: 22), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 22), label: "My account"),
        ],
      ),
    );
  }

  // Updated _buildSearchField: if readOnly is true, wrap in AbsorbPointer to let the outer GestureDetector handle taps.
  Widget _buildSearchField({
    TextEditingController? controller,
    required IconData icon,
    required String hintText,
    bool isReadOnly = false,
  }) {
    Widget textField = TextField(
      controller: controller,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black54, size: 20),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: isReadOnly ? AbsorbPointer(child: textField) : textField,
    );
  }

  Widget _buildDiscountCard(String title, String subtitle) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDealCard(String location, String price, String imageUrl) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 4),
          Text(location,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 4),
          Text(price, style: TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}
