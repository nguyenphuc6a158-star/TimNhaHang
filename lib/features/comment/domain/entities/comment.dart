class Comment {
  final String id;
  final String restaurantId;
  final String uid;
  final String userImage;
  final String userName;
  final String imageUrl;
  final String content;
  final DateTime createdAt;
  final double rating;

  const Comment({
    required this.id,
    required this.restaurantId,
    required this.uid,
    required this.userImage,
    required this.userName,
    required this.rating,
    required this.createdAt,
    required this.content,
    required this.imageUrl,
  });

  @override
  String toString() {
    return "Comment(id: $id, restaurantId: $restaurantId, uid: $uid, userImage: $userImage, userName: $userName, imageUrl: $imageUrl, content: $content, rating: $rating";
  }
}
