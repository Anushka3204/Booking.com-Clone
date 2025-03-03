import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/hotel_service.dart';
import '../screens/hotels2.dart';

class HotelListScreen extends StatefulWidget {
  final String destination;
  final String checkIn;
  final String checkOut;
  final String rooms;

  const HotelListScreen({
    Key? key,
    required this.destination,
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
  }) : super(key: key);

  @override
  _HotelListScreenState createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late Future<List<Destination>> _futureDestinations;
  Set<String> favourites = {};

  @override
  void initState() {
    super.initState();
    _futureDestinations = HotelService.fetchDestinations(
      destinationQuery: widget.destination,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      rooms: widget.rooms,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.orange, width: 6),
          ),
          child: Row(
            children: [
              SizedBox(width: 10, height: 10),
              Text(
                "${widget.destination} · ${widget.checkIn} - ${widget.checkOut}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w100,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.swap_vert, color: Colors.black),
                Icon(Icons.tune, color: Colors.black),
                Icon(Icons.map, color: Colors.black),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Destination>>(
              future: _futureDestinations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No hotels found"));
                } else {
                  final destinations = snapshot.data!;
                  return ListView.builder(
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      final dest = destinations[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        dest.imageUrl
                                            .replaceAll("150x150", "1024x768"),
                                        width: double.infinity,
                                        height: 220,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 220,
                                            color: Colors.grey,
                                            child: Icon(Icons.broken_image,
                                                size: 50, color: Colors.white),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: Icon(
                                          favourites.contains(dest.destId)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color:
                                              favourites.contains(dest.destId)
                                                  ? Colors.red
                                                  : Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (favourites
                                                .contains(dest.destId)) {
                                              favourites.remove(dest.destId);
                                            } else {
                                              favourites.add(dest.destId);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  dest.name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text("${dest.region}, ${dest.country}",
                                    style: TextStyle(color: Colors.grey[700])),
                                SizedBox(height: 5),
                                Text("Hotels Available: ${dest.hotels}",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                Text("City: ${dest.cityName}",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                Text("Destination Type: ${dest.destType}",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Hotels2Screen(
                                            city: dest.cityName,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[900],
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("View Hotels"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
