import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // List of image URLs to be used randomly
  final List<String> imageUrls = [
    "https://cdn.tatlerasia.com/asiatatler/i/hk/2020/01/09104644-ritz-carlton-tokyo-hotel_cover_2000x1126.jpeg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQg7bsHfSAOB97r5H0XrYZ702JstcrFKWihHw&s",
    "https://media.cntraveler.com/photos/5c9b977820c9d49e753a2abd/master/w_320%2Cc_limit/Andaz-Tokyo-Lobby-highres.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRM_UQ74hVk2psb3BaHscDxBhEzyxfhqtSHUg&s",
    "https://www.ghmhotels.com/wp-content/uploads/Chedi-andermatt1-550x360.jpg",
    "https://www.ultimatedrivingtours.com/images/luxury-swiss-hotels/a-img.webp",
    "https://media-cdn.tripadvisor.com/media/photo-s/29/43/d9/93/daisy-boutique-hotel.jpg",
    "https://etimg.etb2bimg.com/photo/102469825.cms",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5leKm-aiFM92elcXK_25sPuhlTghcFrO0Rg&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRu6vzvaD_LIliwkgNETgtU-w8Nf1aZnC2hFg&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiKa1fpI2pXSR6QWgmTbbnZ3mPlraRgU0jHg&s",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcREN4SBpIDI6rn2fcFfTYmqTU-Cq04uTWII-A&s",
    "https://www.myboutiquehotel.com/photos/117756/the-fifth-avenue-hotel-new-york-001-90377-728x400.jpg"
  ];

  // Function to add hotels data
  Future<void> addHotelsData() async {
    // List of cities with their hotel details
    List<Map<String, dynamic>> cities = [
      {
        'city': 'Paris',
        'hotels': [
          {
            'name': 'Hotel Ritz Paris',
            'description':
                'A luxurious hotel in the heart of Paris with top-notch amenities.',
            'facilities': 'Free WiFi, Spa, Pool, Restaurant, Bar',
            'availableRooms': '15',
            'priceRange': '₹9,840 - ₹16,400',
            'rating': '4.8'
          },
          {
            'name': 'Le Meurice',
            'description':
                'A beautiful historic hotel with stunning views of the city.',
            'facilities': 'Spa, Room Service, Heated Pool, Free Breakfast',
            'availableRooms': '12',
            'priceRange': '₹13,300 - ₹22,000',
            'rating': '4.9'
          },
          {
            'name': 'Hotel de Crillon',
            'description':
                'A palace hotel with a rich history and modern luxury.',
            'facilities': 'Free WiFi, Spa, Pool, Restaurant',
            'availableRooms': '10',
            'priceRange': '₹20,000 - ₹40,000',
            'rating': '4.7'
          },
          {
            'name': 'Shangri-La Hotel Paris',
            'description':
                'A grand hotel with breathtaking views of the Eiffel Tower.',
            'facilities': 'Spa, Swimming Pool, Restaurant, Lounge',
            'availableRooms': '20',
            'priceRange': '₹25,000 - ₹45,000',
            'rating': '5.0'
          },
          {
            'name': 'Le Bristol Paris',
            'description':
                'A luxurious hotel offering fine dining and world-class amenities.',
            'facilities': 'Spa, Restaurant, Bar, Free WiFi',
            'availableRooms': '18',
            'priceRange': '₹15,000 - ₹30,000',
            'rating': '4.8'
          },
          {
            'name': 'Mandarin Oriental Paris',
            'description':
                'A contemporary luxury hotel with Michelin-starred dining.',
            'facilities': 'Spa, Restaurant, Heated Pool, Free WiFi',
            'availableRooms': '22',
            'priceRange': '₹20,000 - ₹35,000',
            'rating': '4.9'
          },
          {
            'name': 'The Peninsula Paris',
            'description':
                'An iconic hotel with impeccable service and luxury.',
            'facilities': 'Free WiFi, Spa, Restaurant, Lounge',
            'availableRooms': '25',
            'priceRange': '₹28,000 - ₹50,000',
            'rating': '4.9'
          },
          {
            'name': 'Four Seasons Hotel George V',
            'description':
                'A luxury hotel offering top-tier services and elegant rooms.',
            'facilities': 'Free WiFi, Spa, Restaurant, Bar',
            'availableRooms': '30',
            'priceRange': '₹35,000 - ₹60,000',
            'rating': '5.0'
          }
        ]
      },
      {
        'city': 'New York',
        'hotels': [
          {
            'name': 'The Plaza Hotel',
            'description':
                'Iconic hotel offering elegance, luxury, and outstanding service.',
            'facilities': 'Free WiFi, Spa, Restaurant, Bar',
            'availableRooms': '10',
            'priceRange': '₹18,000 - ₹30,000',
            'rating': '4.7'
          },
          {
            'name': 'Hotel Chelsea',
            'description':
                'A historic hotel located in the heart of Manhattan.',
            'facilities': 'Room Service, Free Breakfast, Conference Room',
            'availableRooms': '20',
            'priceRange': '₹14,000 - ₹24,600',
            'rating': '4.3'
          },
          {
            'name': 'The Standard, High Line',
            'description':
                'A modern, stylish hotel with great city views and rooftop bar.',
            'facilities': 'Free WiFi, Rooftop Bar, Room Service',
            'availableRooms': '18',
            'priceRange': '₹12,500 - ₹21,500',
            'rating': '4.5'
          },
          {
            'name': 'The St. Regis New York',
            'description':
                'A classic luxury hotel with exceptional service and timeless elegance.',
            'facilities': 'Free WiFi, Spa, Restaurant, Lounge',
            'availableRooms': '15',
            'priceRange': '₹22,000 - ₹45,000',
            'rating': '5.0'
          },
          {
            'name': 'W New York',
            'description': 'Chic and trendy hotel with a vibrant atmosphere.',
            'facilities': 'Spa, Restaurant, Free WiFi',
            'availableRooms': '25',
            'priceRange': '₹18,500 - ₹28,000',
            'rating': '4.6'
          },
          {
            'name': 'Hotel Indigo Lower East Side',
            'description':
                'A boutique hotel offering a unique and stylish experience.',
            'facilities': 'Free WiFi, Rooftop Bar, Restaurant',
            'availableRooms': '10',
            'priceRange': '₹12,000 - ₹22,500',
            'rating': '4.4'
          },
          {
            'name': 'Conrad New York Downtown',
            'description':
                'A luxury hotel with spacious suites and modern amenities.',
            'facilities': 'Free WiFi, Restaurant, Spa',
            'availableRooms': '20',
            'priceRange': '₹20,000 - ₹38,000',
            'rating': '4.8'
          },
          {
            'name': 'The Greenwich Hotel',
            'description': 'A chic and elegant hotel located in Tribeca.',
            'facilities': 'Free WiFi, Spa, Restaurant',
            'availableRooms': '15',
            'priceRange': '₹18,000 - ₹35,000',
            'rating': '4.7'
          }
        ]
      },
      {
        'city': 'Tokyo',
        'hotels': [
          {
            'name': 'Andaz Tokyo Toranomon Hills',
            'description':
                'A luxury hotel with a sophisticated blend of modern and traditional design.',
            'facilities': 'Free WiFi, Spa, Restaurant, Lounge',
            'availableRooms': '25',
            'priceRange': '₹10,500 - ₹18,200',
            'rating': '4.8'
          },
          {
            'name': 'Shangri-La Hotel, Tokyo',
            'description':
                'A luxury hotel with beautiful views of Tokyo Bay and Mount Fuji.',
            'facilities': 'Spa, Free Breakfast, Restaurant',
            'availableRooms': '22',
            'priceRange': '₹12,000 - ₹20,000',
            'rating': '4.9'
          },
          {
            'name': 'The Peninsula Tokyo',
            'description':
                'A luxury hotel offering amazing views of the Imperial Palace Gardens.',
            'facilities': 'Free WiFi, Spa, Restaurant, Lounge',
            'availableRooms': '15',
            'priceRange': '₹15,000 - ₹30,000',
            'rating': '4.7'
          },
          {
            'name': 'Park Hyatt Tokyo',
            'description': 'An elegant hotel with panoramic views of the city.',
            'facilities': 'Free WiFi, Spa, Pool, Restaurant',
            'availableRooms': '18',
            'priceRange': '₹20,000 - ₹35,000',
            'rating': '4.9'
          },
          {
            'name': 'Mandarin Oriental Tokyo',
            'description': 'A modern luxury hotel with impeccable service.',
            'facilities': 'Spa, Free WiFi, Restaurant, Bar',
            'availableRooms': '20',
            'priceRange': '₹22,000 - ₹40,000',
            'rating': '5.0'
          }
        ]
      },
    ];

    // Add data for each city and its hotels to Firestore
    for (var city in cities) {
      for (var hotel in city['hotels']) {
        await firestore.collection('hotels').add({
          'city': city['city'],
          'name': hotel['name'],
          'description': hotel['description'],
          'facilities': hotel['facilities'],
          'availableRooms': hotel['availableRooms'],
          'priceRange': hotel['priceRange'],
          'rating': hotel['rating'],
          'image': imageUrls[
              Random().nextInt(imageUrls.length)] // Select a random image URL
        });
      }
    }

    print('Done');
  }
}
