import 'package:cloud_firestore/cloud_firestore.dart';

// Đây là lớp User Entity
class User {
  final String uid;
  final String? displayName;
  final String email;
  final String? photoURL;
  final String? phoneNumber;
  final Timestamp? createdAt;
  // Bạn có thể thêm các trường khác nếu cần

  const User({
    required this.uid,
    this.displayName,
    required this.email,
    this.photoURL,
    this.phoneNumber,
    this.createdAt,
  });

  @override
  String toString() {
    return 'Note(uid: $uid, displayName: $displayName, email: $email, photoURL: $photoURL, phoneNumber: $phoneNumber, name: $createdAt)';
  }
}
