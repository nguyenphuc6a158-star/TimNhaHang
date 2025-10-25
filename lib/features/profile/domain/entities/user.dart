import 'package:cloud_firestore/cloud_firestore.dart';

// User là Entity, chỉ chứa dữ liệu cần thiết cho Logic
class User {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String phoneNumber;
  final Timestamp createdAt;

  const User({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.phoneNumber,
    required this.createdAt,
  });

  @override
  String toString() {
    return 'User(uid: $uid, displayName: $displayName)';
  }
}