
import 'package:timnhahang/features/profile/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String uid);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String uid);
  Future<void> createUser(User user);
}