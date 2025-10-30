import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/comment/domain/entities/comment.dart';

class CommentModel extends Comment {
  CommentModel({
    required super.id,
    required super.restaurantId,
    required super.uid,
    required super.userImage,
    required super.userName,
    required super.rating,
    required super.content,
    required super.imageUrl,
    required super.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      uid: data['uid'] ?? '',
      userName: data['userName'] ?? '',
      content: data['content'] ?? '',
      userImage: data['userImage'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      rating: (data['rating'] ?? 0 as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'restaurantId': restaurantId,
    'userName': userName,
    'content': content,
    'userImage': userImage,
    'imageUrl': imageUrl,
    'rating': rating,
    'created_at': Timestamp.fromDate(createdAt),
  };

  factory CommentModel.fromEntity(Comment e) => CommentModel(
    id: e.id,
    uid: e.uid,
    restaurantId: e.restaurantId,
    content: e.content,
    userName: e.userName,
    userImage: e.userImage,
    imageUrl: e.imageUrl,
    createdAt: e.createdAt,
    rating: e.rating,
  );
}
