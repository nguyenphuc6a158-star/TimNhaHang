import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';

class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  // Hàm này nhận User Entity đã được chỉnh sửa và gửi xuống Repository
  Future<void> call(User user) {
    return repository.updateUser(user);
  }
}
