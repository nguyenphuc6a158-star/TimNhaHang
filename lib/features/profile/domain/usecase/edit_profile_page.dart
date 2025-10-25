import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/usecase/update_user_profile.dart';
// Cần import các lớp để nối dây UpdateUserProfile Usecase (Giả định đã có)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';


class EditProfilePage extends StatefulWidget {
  final User initialUser;

  const EditProfilePage({super.key, required this.initialUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;

  late final UpdateUserProfile updateProfileUseCase;

  String? _error;
  bool _isSaving = false;
  bool _isPasswordSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialUser.displayName);
    phoneController = TextEditingController(text: widget.initialUser.phoneNumber);
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();

    // Nối dây Usecase Update (Giả lập DI)
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = UserRemoteDataSourceImpl(firestore: firestore);
    final repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);
    updateProfileUseCase = UpdateUserProfile(repository);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  // --- HÀM CẬP NHẬT PROFILE (NAME/PHONE) ---
  Future<void> _updateProfile() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final updatedUser = User(
        uid: widget.initialUser.uid,
        email: widget.initialUser.email,
        createdAt: widget.initialUser.createdAt,
        photoURL: widget.initialUser.photoURL,
        displayName: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
      );

      // 1. Gọi Usecase cập nhật Profile (Firestore)
      await updateProfileUseCase.call(updatedUser);

      if (mounted) {
        // Cập nhật thành công, quay lại trang Profile
        Navigator.of(context).pop(updatedUser);
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi cập nhật Profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // --- HÀM CẬP NHẬT MẬT KHẨU (FIREBASE AUTH) ---
  Future<void> _changePassword() async {
    if (_isPasswordSaving) return;

    if (newPasswordController.text.isEmpty || newPasswordController.text.length < 6) {
      setState(() => _error = "Mật khẩu mới phải có ít nhất 6 ký tự.");
      return;
    }

    // Yêu cầu Firebase Auth
    final user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = "Lỗi xác thực: Người dùng không đăng nhập.");
      return;
    }

    setState(() {
      _isPasswordSaving = true;
      _error = null;
    });

    try {
      // 1. Xác thực lại người dùng bằng mật khẩu hiện tại
      final credential = auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Cập nhật mật khẩu mới
      await user.updatePassword(newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!')),
        );
        currentPasswordController.clear();
        newPasswordController.clear();
      }
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'wrong-password') {
          _error = 'Mật khẩu hiện tại không đúng.';
        } else {
          _error = 'Lỗi đổi mật khẩu: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Đã xảy ra lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isPasswordSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
              ),

            // --- PHẦN 1: THÔNG TIN CÁ NHÂN (NAME, PHONE) ---
            const Text("Thông tin cá nhân", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            // Trường Tên Hiển thị
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Tên hiển thị",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 15),

            // Trường Số điện thoại
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 25),

            // Nút Lưu Profile
            ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: _isSaving ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ) : const Icon(Icons.save),
              label: Text(_isSaving ? "Đang lưu..." : "Lưu Thay Đổi Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),

            const SizedBox(height: 40),

            // --- PHẦN 2: THAY ĐỔI MẬT KHẨU (AUTH) ---
            const Text("Thay đổi Mật khẩu (Auth)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),

            // Trường Mật khẩu hiện tại (Bắt buộc để xác thực lại)
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu hiện tại",
                prefixIcon: Icon(Icons.lock_person_outlined),
              ),
            ),
            const SizedBox(height: 15),

            // Trường Mật khẩu mới
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu mới (Tối thiểu 6 ký tự)",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 25),

            // Nút Đổi Mật khẩu
            ElevatedButton.icon(
              onPressed: _changePassword,
              icon: _isPasswordSaving ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ) : const Icon(Icons.vpn_key_outlined),
              label: Text(_isPasswordSaving ? "Đang đổi..." : "Đổi Mật Khẩu"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
