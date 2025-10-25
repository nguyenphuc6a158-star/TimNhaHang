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

  // Chuyển đổi từ DocumentSnapshot của Firestore sang UserModel
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

  // Chuyển đổi từ UserModel sang Map để ghi lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
    };
  }
}