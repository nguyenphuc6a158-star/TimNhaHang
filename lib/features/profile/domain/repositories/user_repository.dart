import 'package:timnhahang/features/profile/domain/entities/user.dart';

// Abstract class, định nghĩa những gì có thể làm với dữ liệu User
abstract class UserRepository {
  // Lấy profile theo UID
  Future<User> getUserProfile(String uid);

  // Cập nhật profile
  Future<void> updateProfile(User user);

}