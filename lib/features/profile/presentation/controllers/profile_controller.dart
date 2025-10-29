import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:timnhahang/features/profile/domain/usecase/update_user_profile.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

// Import cho Usecase đổi mật khẩu
import 'package:timnhahang/features/profile/domain/usecase/change_password.dart';
import 'package:timnhahang/features/profile/data/repositories/auth_repository_impl.dart';

class ProfileController extends ChangeNotifier {
  User? profile;
  bool isLoading = true;
  bool isSaving = false;
  bool isChangingPassword = false; // Cờ loading mới

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPwdController = TextEditingController();
  final newPwdController = TextEditingController();

  late final GetUserProfile _getProfile;
  late final UpdateUserProfile _updateProfile;
  late final ChangePasswordUseCase _changePassword; // Usecase mới
  final _auth = fb.FirebaseAuth.instance;

  Future<void> init() async {
    // Khởi tạo UserRepository
    final userRepo = UserRepositoryImpl(
      remoteDataSource: UserRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
    );
    // Khởi tạo AuthRepository
    final authRepo = AuthRepositoryImpl(_auth);

    // Khởi tạo Usecase
    _getProfile = GetUserProfile(userRepo);
    _updateProfile = UpdateUserProfile(userRepo);
    _changePassword = ChangePasswordUseCase(authRepo);

    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Giả định profile luôn tồn tại sau khi đăng ký
      profile = await _getProfile(uid);
      nameController.text = profile!.displayName ?? '';
      phoneController.text = profile!.phoneNumber ?? '';
    } catch (e) {
      // Xử lý lỗi tải profile
      print("Lỗi tải Profile: $e");
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    if (profile == null || isSaving) return;

    isSaving = true;
    notifyListeners();

    try {
      final updated = profile!.copyWith(
        displayName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      // Cập nhật Auth và Firestore
      await _auth.currentUser!.updateDisplayName(updated.displayName);
      await _updateProfile(updated);

      profile = updated;
      _showSnackBar(context, 'Lưu thành công!', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Lỗi: ${e.toString()}', Colors.red);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<void> updateAvatar(BuildContext context, String url) async {
    if (profile == null) return;

    try {
      final updated = profile!.copyWith(photoURL: url.trim());
      await _auth.currentUser!.updatePhotoURL(updated.photoURL);
      await _updateProfile(updated);
      profile = updated;
      notifyListeners();
      _showSnackBar(context, 'Cập nhật avatar thành công!', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Lỗi: ${e.toString()}', Colors.red);
    }
  }

  // Hàm đổi mật khẩu đã được viết lại để gọi Usecase
  Future<void> changePassword(BuildContext context) async {
    final current = currentPwdController.text.trim();
    final newPwd = newPwdController.text.trim();

    if (current.isEmpty || newPwd.isEmpty) {
      _showSnackBar(context, 'Vui lòng điền đầy đủ', Colors.orange);
      return;
    }

    isChangingPassword = true;
    notifyListeners();

    // Gọi Usecase để xử lý logic đổi mật khẩu
    final String? error = await _changePassword(current, newPwd);

    if (error == null) {
      currentPwdController.clear();
      newPwdController.clear();
      _showSnackBar(context, 'Đổi mật khẩu thành công!', Colors.green);
    } else {
      _showSnackBar(context, error, Colors.red);
    }

    isChangingPassword = false;
    notifyListeners();
  }

  // Hàm createProfile đã được loại bỏ

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    currentPwdController.dispose();
    newPwdController.dispose();
    super.dispose();
  }
}
