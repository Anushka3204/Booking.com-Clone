import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DataUploader {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data for each city with 10 hotels
  final Map<String, List<Map<String, dynamic>>> cityHotelsData = {
    'Shimla': [
      {
        'name': 'Hotel Snow View Shimla',
        'description':
            'A luxury hotel with stunning views of the snow-capped mountains.',
        'facilities': 'Free WiFi, Restaurant, Room Service, Conference Room',
        'availableRooms': 20,
        'priceRange': '\$120 - \$200',
        'imageUrl':
            'https://cdn.tatlerasia.com/asiatatler/i/hk/2020/01/09104644-ritz-carlton-tokyo-hotel_cover_2000x1126.jpeg',
        'rating': 4.5,
      },
      {
        'name': 'Shimla Heritage Hotel',
        'description': 'A charming heritage hotel with colonial architecture.',
        'facilities': 'Free Parking, Spa, Laundry, Restaurant',
        'availableRooms': 15,
        'priceRange': '\$100 - \$160',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg7bsHfSAOB97r5H0XrYZ702JstcrFKWihHw&s',
        'rating': 4.2,
      },
      {
        'name': 'The Oberoi Cecil Shimla',
        'description': 'An iconic hotel offering elegance and old-world charm.',
        'facilities': 'Free WiFi, Spa, Fine Dining, Bar',
        'availableRooms': 12,
        'priceRange': '\$180 - \$300',
        'imageUrl':
            'https://media.cntraveler.com/photos/5c9b977820c9d49e753a2abd/master/w_320%2Cc_limit/Andaz-Tokyo-Lobby-highres.jpg',
        'rating': 4.8,
      },
      {
        'name': 'Wildflower Hall Shimla',
        'description':
            'Nestled in the Himalayan mountains with luxurious amenities.',
        'facilities': 'Pool, Spa, Free WiFi, Fitness Center',
        'availableRooms': 22,
        'priceRange': '\$200 - \$350',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRM_UQ74hVk2psb3BaHscDxBhEzyxfhqtSHUg&s',
        'rating': 5.0,
      },
      {
        'name': 'Radisson Hotel Shimla',
        'description': 'A modern hotel with scenic views of the valley.',
        'facilities': 'Free WiFi, Room Service, Conference Room, Restaurant',
        'availableRooms': 25,
        'priceRange': '\$140 - \$250',
        'imageUrl':
            'https://www.ghmhotels.com/wp-content/uploads/Chedi-andermatt1-550x360.jpg',
        'rating': 4.3,
      },
      {
        'name': 'Woodville Palace Hotel',
        'description': 'Experience royal hospitality in a palatial setting.',
        'facilities': 'Free WiFi, Spa, Parking, Laundry',
        'availableRooms': 18,
        'priceRange': '\$130 - \$220',
        'imageUrl':
            'https://www.ultimatedrivingtours.com/images/luxury-swiss-hotels/a-img.webp',
        'rating': 4.6,
      },
      {
        'name': 'Shilon Resort Shimla',
        'description':
            'A secluded resort with breathtaking views and adventure sports.',
        'facilities': 'Free WiFi, Restaurant, Spa, Adventure Activities',
        'availableRooms': 17,
        'priceRange': '\$150 - \$230',
        'imageUrl':
            'https://cdn.tatlerasia.com/asiatatler/i/hk/2020/01/09104644-ritz-carlton-tokyo-hotel_cover_2000x1126.jpeg',
        'rating': 4.4,
      },
      {
        'name': 'Snow King Retreat Shimla',
        'description':
            'A cozy retreat with a warm ambiance and spectacular views.',
        'facilities': 'Free WiFi, Parking, Restaurant, Room Service',
        'availableRooms': 12,
        'priceRange': '\$110 - \$180',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg7bsHfSAOB97r5H0XrYZ702JstcrFKWihHw&s',
        'rating': 4.0,
      },
      {
        'name': 'Shimla Hills Resort',
        'description': 'A tranquil getaway in the scenic Shimla Hills.',
        'facilities': 'Free WiFi, Spa, Restaurant, Gym',
        'availableRooms': 15,
        'priceRange': '\$120 - \$210',
        'imageUrl':
            'https://media.cntraveler.com/photos/5c9b977820c9d49e753a2abd/master/w_320%2Cc_limit/Andaz-Tokyo-Lobby-highres.jpg',
        'rating': 4.6,
      },
      {
        'name': 'Clouds End Shimla',
        'description':
            'Located at the highest point of Shimla with panoramic views.',
        'facilities': 'Free WiFi, Restaurant, Conference Room, Bar',
        'availableRooms': 20,
        'priceRange': '\$150 - \$220',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRM_UQ74hVk2psb3BaHscDxBhEzyxfhqtSHUg&s',
        'rating': 4.7,
      }
    ],
    'Udaipur': [
      {
        'name': 'Lake Palace Udaipur',
        'description': 'A beautiful palace with a mesmerizing lake view.',
        'facilities': 'Swimming Pool, Spa, Free WiFi, Restaurant',
        'availableRooms': 15,
        'priceRange': '\$150 - \$250',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg7bsHfSAOB97r5H0XrYZ702JstcrFKWihHw&s',
        'rating': 4.8,
      },
      {
        'name': 'Jag Mandir Udaipur',
        'description': 'An exquisite palace on an island in Lake Pichola.',
        'facilities': 'Spa, Free WiFi, Fine Dining, Boat Ride',
        'availableRooms': 18,
        'priceRange': '\$170 - \$270',
        'imageUrl':
            'https://media.cntraveler.com/photos/5c9b977820c9d49e753a2abd/master/w_320%2Cc_limit/Andaz-Tokyo-Lobby-highres.jpg',
        'rating': 4.9,
      },
      {
        'name': 'The Oberoi Udaivilas',
        'description': 'A stunning luxury hotel with world-class amenities.',
        'facilities': 'Spa, Swimming Pool, Free WiFi, Fitness Center',
        'availableRooms': 22,
        'priceRange': '\$250 - \$450',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRM_UQ74hVk2psb3BaHscDxBhEzyxfhqtSHUg&s',
        'rating': 5.0,
      },
      {
        'name': 'Trident Udaipur',
        'description':
            'A peaceful resort with beautiful gardens and a serene lake.',
        'facilities': 'Spa, Free WiFi, Pool, Restaurant',
        'availableRooms': 20,
        'priceRange': '\$150 - \$220',
        'imageUrl':
            'https://www.ghmhotels.com/wp-content/uploads/Chedi-andermatt1-550x360.jpg',
        'rating': 4.7,
      },
      {
        'name': 'Fateh Prakash Palace',
        'description': 'A historic palace with magnificent royal architecture.',
        'facilities': 'Free WiFi, Spa, Restaurant, Room Service',
        'availableRooms': 14,
        'priceRange': '\$120 - \$190',
        'imageUrl':
            'https://www.ultimatedrivingtours.com/images/luxury-swiss-hotels/a-img.webp',
        'rating': 4.4,
      },
      {
        'name': 'Shiv Niwas Palace',
        'description':
            'A beautiful palace offering traditional Rajasthani hospitality.',
        'facilities': 'Free WiFi, Restaurant, Conference Room, Bar',
        'availableRooms': 16,
        'priceRange': '\$130 - \$210',
        'imageUrl':
            'https://cdn.tatlerasia.com/asiatatler/i/hk/2020/01/09104644-ritz-carlton-tokyo-hotel_cover_2000x1126.jpeg',
        'rating': 4.5,
      },
      {
        'name': 'Lalit Laxmi Vilas Palace',
        'description':
            'A luxurious palace with stunning interiors and breathtaking views.',
        'facilities': 'Spa, Free WiFi, Restaurant, Swimming Pool',
        'availableRooms': 19,
        'priceRange': '\$160 - \$240',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg7bsHfSAOB97r5H0XrYZ702JstcrFKWihHw&s',
        'rating': 4.7,
      },
      {
        'name': 'Mewar Haveli',
        'description': 'A budget-friendly yet comfortable hotel near the lake.',
        'facilities': 'Free WiFi, Parking, Restaurant, Room Service',
        'availableRooms': 24,
        'priceRange': '\$90 - \$160',
        'imageUrl':
            'https://media.cntraveler.com/photos/5c9b977820c9d49e753a2abd/master/w_320%2Cc_limit/Andaz-Tokyo-Lobby-highres.jpg',
        'rating': 4.2,
      },
      {
        'name': 'Udaipur Royal Palace',
        'description': 'A majestic palace offering both luxury and comfort.',
        'facilities': 'Free WiFi, Restaurant, Spa, Pool',
        'availableRooms': 20,
        'priceRange': '\$140 - \$210',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRM_UQ74hVk2psb3BaHscDxBhEzyxfhqtSHUg&s',
        'rating': 4.6,
      },
      {
        'name': 'Radisson Blu Resort',
        'description':
            'A beautiful resort offering a peaceful escape with modern amenities.',
        'facilities': 'Free WiFi, Swimming Pool, Fitness Center, Bar',
        'availableRooms': 25,
        'priceRange': '\$160 - \$240',
        'imageUrl':
            'https://www.ghmhotels.com/wp-content/uploads/Chedi-andermatt1-550x360.jpg',
        'rating': 4.4,
      }
    ]
  };

  // Method to upload hotel data to Firestore
  Future<void> uploadData() async {
    for (var city in cityHotelsData.keys) {
      for (var hotel in cityHotelsData[city]!) {
        await _firestore.collection('hotels').add({
          'city': city,
          'name': hotel['name'],
          'description': hotel['description'],
          'facilities': hotel['facilities'],
          'availableRooms': hotel['availableRooms'],
          'priceRange': hotel['priceRange'],
          'imageUrl': hotel['imageUrl'],
          'rating': hotel['rating'],
        });
      }
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Data Uploader',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hotel Data Uploader'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              DataUploader uploader = DataUploader();
              await uploader.uploadData();
            },
            child: Text('Upload Data'),
          ),
        ),
      ),
    );
  }
}
