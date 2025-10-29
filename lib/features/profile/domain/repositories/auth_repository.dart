// domain/repository/auth_repository.dart
abstract class AuthRepository {
  // Trả về lỗi (String) nếu thất bại, hoặc null nếu thành công
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}