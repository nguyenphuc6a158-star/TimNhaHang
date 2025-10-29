import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

// UserModel kế thừa User, thêm các phương thức chuyển đổi dữ liệu
class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.photoURL,
    required super.phoneNumber,
    required super.createdAt, 
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'photoURL': photoURL,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt,
  };
  factory UserModel.fromEntity(User e) => UserModel(
    uid: e.uid,
    displayName: e.displayName,
    email: e.email,
    photoURL: e.photoURL,
    phoneNumber: e.phoneNumber,
    createdAt: e.createdAt,
  );  
}