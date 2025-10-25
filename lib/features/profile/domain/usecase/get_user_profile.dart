import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';

class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  // Usecase chỉ thực thi nghiệp vụ thông qua Repository
  Future<User> call(String uid) {
    return repository.getUserProfile(uid);
  }
}

// Thêm usecase cập nhật nếu cần:
/*
class UpdateUserProfile {
  final UserRepository repository;
  UpdateUserProfile(this.repository);
  Future<void> call(User user) => repository.updateProfile(user);
}
*/