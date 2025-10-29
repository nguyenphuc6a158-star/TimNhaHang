// domain/usecase/change_password.dart
import 'package:timnhahang/features/profile/domain/repositories/auth_repository.dart';
class ChangePasswordUseCase {
  final AuthRepository repository;
  ChangePasswordUseCase(this.repository);

  // Gọi Usecase như một hàm
  Future<String?> call(String currentPassword, String newPassword) async {
    if (newPassword.length < 6) {
      return 'Mật khẩu mới phải ≥ 6 ký tự';
    }
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}