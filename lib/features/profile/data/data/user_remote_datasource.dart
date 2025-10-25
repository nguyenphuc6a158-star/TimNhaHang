import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/profile/data/models/user_model.dart';

// Abstract class định nghĩa các hàm lấy dữ liệu từ nguồn (Firestore)
abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile(String uid);
  Future<void> updateProfile(UserModel user);
}

// Triển khai thực tế để tương tác với Firestore
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<UserModel> getUserProfile(String uid) async {
    final docSnapshot = await firestore.collection('users').doc(uid).get();

    if (docSnapshot.exists) {
      return UserModel.fromFirestore(docSnapshot);
    } else {
      throw Exception('User profile not found for UID: $uid');
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    await firestore.collection('users').doc(user.uid).update(user.toMap());
  }
}