import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyFavourites extends StatefulWidget {
  @override
  _MyFavouritesState createState() => _MyFavouritesState();
}

class _MyFavouritesState extends State<MyFavourites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favourites"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('favourites')
            .snapshots(), // Fetch all favourites
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No favourites found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var favourite = snapshot.data!.docs[index];
              return _buildFavouriteCard(favourite);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavouriteCard(QueryDocumentSnapshot favourite) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              favourite['image'],
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
                  favourite['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text("City: ${favourite['city']}"),
                SizedBox(height: 5),
                Text("Available Rooms: ${favourite['availableRooms']}"),
                SizedBox(height: 5),
                Text("Facilities: ${favourite['facilities']}"),
                SizedBox(height: 5),
                Text("Description: ${favourite['description']}"),
                SizedBox(height: 5),
                Text("Price Range: ${favourite['priceRange']}"),
                SizedBox(height: 5),
                Text("Rating: ${favourite['rating']} ⭐"),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _confirmRemoveFavourite(favourite.id),
                    icon: Icon(Icons.favorite, color: Colors.red),
                    label: Text(
                      "Remove Favourite",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveFavourite(String favouriteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove Favourite"),
        content: Text("Are you sure you want to remove this from favourites?"),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Yes, Remove"),
            onPressed: () {
              _removeFavourite(favouriteId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _removeFavourite(String favouriteId) async {
    await FirebaseFirestore.instance
        .collection('favourites')
        .doc(favouriteId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Favourite removed successfully")),
    );
  }
}
