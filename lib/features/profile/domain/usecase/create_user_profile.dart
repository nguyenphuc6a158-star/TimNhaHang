import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';

class CreateUserProfile {
  final UserRepository repository;

  CreateUserProfile(this.repository);

  // Hàm này nhận một User Entity cơ bản và tạo tài liệu trên Firestore
  Future<void> call(User user) {
    return repository.createProfile(user);
  }
}