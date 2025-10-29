import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';

class GetUserProfile{
  final UserRepository repository;
  GetUserProfile(this.repository);
  Future<User> call(String uid) {
    return repository.getUser(uid);
  }
}