// // lib/models/hotel_model.dart
// class Hotel {
//   final String name;
//   final String address;
//   final String price;
//   final String imageUrl;

//   Hotel({
//     required this.name,
//     required this.address,
//     required this.price,
//     required this.imageUrl,
//   });

//   factory Hotel.fromJson(Map<String, dynamic> json) {
//     return Hotel(
//       name: json['hotel_name'] ?? 'No Name',
//       address: json['address'] ?? 'No Address',
//       price: json['price']?.toString() ?? 'N/A',
//       imageUrl: json['image_url'] ?? '',
//     );
//   }
// }

// lib/models/hotel_model.dart
class Hotel {
  final String id;
  final String name;
  final String city; // Add city
  final String country; // Add country
  final String description;
  final double rating;
  final String imageUrl;
  final String phoneNumber;
  final List<String> amenities;
  final double price; // Add price

  Hotel({
    required this.id,
    required this.name,
    required this.city, // Add city
    required this.country, // Add country
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.phoneNumber,
    required this.amenities,
    required this.price, // Add price
  });

  // Factory constructor to parse JSON response
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '', // Parse city
      country: json['country'] ?? '', // Parse country
      description: json['description'] ?? '',
      rating: (json['rating'] != null) ? json['rating'].toDouble() : 0.0,
      imageUrl: json['imageUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      amenities:
          json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      price: (json['price'] != null)
          ? json['price'].toDouble()
          : 0.0, // Parse price
    );
  }

  // Method to convert the Hotel object to a map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city, // Add city
      'country': country, // Add country
      'description': description,
      'rating': rating,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'amenities': amenities,
      'price': price, // Add price
    };
  }
}
