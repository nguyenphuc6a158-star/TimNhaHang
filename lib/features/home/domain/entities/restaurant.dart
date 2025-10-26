class Restaurant {
  final String address;
  final String category;
  final String closing;
  final String imageUrl;
  final String name;
  final String opening;
  final String priceRange;
  final double rating;
  final bool saved;

  const Restaurant({
    required this.address,
    required this.category,
    required this.closing,
    required this.imageUrl,
    required this.name,
    required this.opening,
    required this.priceRange,
    required this.rating,
    required this.saved,
  });
  @override
  String toString() {
    return 'Note(address: $address,category: $category, closing: $closing, imageUrl: $imageUrl, '
        'name: $name, opening: $opening, priceRange: $priceRange, rating: $rating, saved: $saved)';
  }
}