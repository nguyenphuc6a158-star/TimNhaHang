// data/repository/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:timnhahang/features/profile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _auth;
  AuthRepositoryImpl(this._auth);

  @override
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser!;
      // 1. Xác thực lại
      await user.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        ),
      );
      // 2. Cập nhật mật khẩu mới
      await user.updatePassword(newPassword);
      return null; // Thành công
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'Mật khẩu hiện tại sai';
      }
      return 'Có lỗi xảy ra khi đổi mật khẩu';
    } catch (e) {
      return e.toString();
    }
  }
}