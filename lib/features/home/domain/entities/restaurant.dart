class Restaurant {
  final String address;
  final String category;
  final String city;
  final String closing;
  final String coordinates;
  final String district;
  final String imageUrl;
  final String name;
  final String opening;
  final String priceRange;
  final double rating;

  const Restaurant({
    required this.address,
    required this.category,
    required this.city,
    required this.closing,
    required this.coordinates,
    required this.district,
    required this.imageUrl,
    required this.name,
    required this.opening,
    required this.priceRange,
    required this.rating,
  });
  @override
  String toString() {
    return 'Note(address: $address,category: $category, city: $city, closing: $closing, '
        'coordinates: $coordinates, district: $district, imageUrl: $imageUrl, '
        'name: $name, opening: $opening, priceRange: $priceRange, rating: $rating)';
  }
}