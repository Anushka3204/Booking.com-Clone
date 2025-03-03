import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './BookingFormScreen.dart';

class Hotels2Screen extends StatefulWidget {
  final String city;

  const Hotels2Screen({Key? key, required this.city}) : super(key: key);

  @override
  _Hotels2ScreenState createState() => _Hotels2ScreenState();
}

class _Hotels2ScreenState extends State<Hotels2Screen> {
  late Future<List<Map<String, dynamic>>> _hotels;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> favoriteHotelIds = [];

  @override
  void initState() {
    super.initState();
    _hotels = fetchHotels(widget.city);
    fetchFavorites();
  }

  Future<List<Map<String, dynamic>>> fetchHotels(String city) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('hotels')
          .where('city', isEqualTo: city)
          .get();

      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Store document ID
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching hotels: $e");
      return [];
    }
  }

  Future<void> fetchFavorites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('favourites').get();
      setState(() {
        favoriteHotelIds =
            snapshot.docs.map((doc) => doc.id).toList(); // Store fav hotel IDs
      });
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  Future<void> toggleFavorite(Map<String, dynamic> hotel) async {
    String hotelId = hotel['id'];

    if (favoriteHotelIds.contains(hotelId)) {
      // Remove from favorites
      await _firestore.collection('favourites').doc(hotelId).delete();
      setState(() {
        favoriteHotelIds.remove(hotelId);
      });
    } else {
      // Add to favorites
      await _firestore.collection('favourites').doc(hotelId).set(hotel);
      setState(() {
        favoriteHotelIds.add(hotelId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: Text("Hotels in ${widget.city}",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hotels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hotels found in ${widget.city}"));
          } else {
            final hotels = snapshot.data!;
            return ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                double rating =
                    double.tryParse(hotel['rating'].toString()) ?? 0.0;
                bool isFavorite = favoriteHotelIds.contains(hotel['id']);

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  hotel[
                                      'image'], // Ensure this field matches Firestore
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                hotel['name'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text("Description: ${hotel['description']}"),
                              SizedBox(height: 5),
                              Text("Facilities: ${hotel['facilities']}"),
                              SizedBox(height: 5),
                              Text(
                                  "Rooms available: ${hotel['availableRooms']}"),
                              SizedBox(height: 5),
                              Text("Price Range: ${hotel['priceRange']}"),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  _buildRatingStars(rating),
                                  SizedBox(width: 8),
                                  Text("Rating: $rating",
                                      style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookingFormScreen(
                                          hotel: hotel,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text("Book Now",
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () => toggleFavorite(hotel),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      Icon starIcon = (i <= rating)
          ? Icon(Icons.star,
              color: const Color.fromARGB(255, 212, 222, 99), size: 20)
          : Icon(Icons.star_border,
              color: const Color.fromARGB(255, 232, 220, 105), size: 20);
      stars.add(starIcon);
    }
    return Row(
      children: stars,
    );
  }
}
