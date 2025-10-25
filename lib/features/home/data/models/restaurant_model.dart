import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.address,
    required super.category,
    required super.city,
    required super.closing,
    required super.coordinates,
    required super.district,
    required super.imageUrl,
    required super.name,
    required super.opening,
    required super.priceRange,
    required super.rating,
  });
  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      address: data['address'] ?? '',
      category: data['category'] ?? '',
      city: data['city'] ?? '',
      closing: data['closing'] ?? '',
      coordinates: data['coordinates'] ?? '',
      district: data['district'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      opening: data['opening'] ?? '',
      priceRange: data['priceRange'] ?? '',
      rating: data['rating'] ?? 0,
    );
  }
}