import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';

class SaveModel extends Save {
  SaveModel({
    required super.id,
    required super.restaurantId,
    required super.uid,
    required super.restaurantName,
    required super.restaurantAddress,
    required super.imageUrl,
    required super.createdAt,
  });

  factory SaveModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaveModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      uid: data['uid'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      restaurantAddress: data['restaurantAddress'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'restaurantId': restaurantId,
    'uid': uid,
    'restaurantName': restaurantName,
    'restaurantAddress': restaurantAddress,
    'imageUrl': imageUrl,
    'created_at': Timestamp.fromDate(createdAt),
  };

  factory SaveModel.fromEntity(Save e) => SaveModel(
    id: e.id,
    restaurantId: e.restaurantId,
    uid: e.uid,
    restaurantName: e.restaurantName,
    restaurantAddress: e.restaurantAddress,
    createdAt: e.createdAt,
    imageUrl: e.imageUrl,
  );
}
