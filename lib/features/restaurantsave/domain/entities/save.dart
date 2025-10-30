class Save {
  final String id;
  final String restaurantId;
  final String uid;
  final String imageUrl;
  final String restaurantName;
  final DateTime createdAt;
  final String restaurantAddress;

  const Save({
    required this.id,
    required this.restaurantId,
    required this.uid,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.imageUrl,
    required this.createdAt,
  });

  @override
  String toString() {
    return "Save(id: $id, restaurantId: $restaurantId, uid: $uid, restaurantName: $restaurantName, restaurantAddress: $restaurantAddress, imageUrl: $imageUrl)";
  }
}