import 'package:cloud_firestore/cloud_firestore.dart';

// Đây là lớp User Entity
class User {
  final String uid;
  final String? displayName;
  final String email;
  final String? photoURL;
  final String? phoneNumber;
  final Timestamp createdAt;
  // Bạn có thể thêm các trường khác nếu cần

  const User({
    required this.uid,
    this.displayName,
    required this.email,
    this.photoURL,
    this.phoneNumber,
    required this.createdAt,
  });

  // PHƯƠNG THỨC copyWith được yêu cầu
  User copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? phoneNumber,
    Timestamp? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
