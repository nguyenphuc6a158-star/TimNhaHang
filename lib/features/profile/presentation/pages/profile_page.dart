// (GIỮ NGUYÊN) Imports từ code gốc của bạn
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:timnhahang/features/profile/domain/usecase/update_user_profile.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- (GIỮ NGUYÊN) Phần khởi tạo dependencies của bạn ---
  late final UsersRemoteDataSourceImpl _remote = UsersRemoteDataSourceImpl();
  late final UserRepositoryImpl _repo = UserRepositoryImpl(_remote);
  late final GetUserProfile _getUser = GetUserProfile(_repo);

  // (CHỈNH SỬA) 'user' được đổi tên thành '_currentUserProfile' để khớp với code mới
  User? _currentUserProfile;

  // --- (THÊM) State, Controllers, và Usecases từ code mẫu ---
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Controllers
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  // Usecase (sẽ được khởi tạo trong initState)
  late final UpdateUserProfile _updateUserProfile;

  // Firebase Services
  final _auth = fb.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    // (THÊM) Khởi tạo usecase *mới* sử dụng _repo *có sẵn* của bạn
    _updateUserProfile = UpdateUserProfile(_repo);

    // (CHỈNH SỬA) Gọi hàm fetch mới thay vì _loadUser
    _fetchUserProfile();
  }

  // (THÊM) Hàm dispose cho controllers
  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  // (CHỈNH SỬA) Nâng cấp _loadUser thành _fetchUserProfile
  // (Hàm này thay thế hàm _loadUser() gốc của bạn)
  Future<void> _fetchUserProfile() async {
    final uid = widget.uid;

    try {
      // (GIỮ NGUYÊN) Sử dụng _getUser (từ code gốc của bạn)
      final profile = await _getUser(uid);
      if (!mounted) return;
      setState(() {
        _currentUserProfile = profile; // Cập nhật state
        _displayNameController.text = profile.displayName ?? '';
        _phoneNumberController.text = profile.phoneNumber ?? '';
        _avatarUrlController.text = profile.photoURL ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Lỗi tải: Tài khoản chưa có dữ liệu Profile. Vui lòng cập nhật.';
        _isLoading = false;
      });
    }
  }

  // (THÊM) Hàm hiển thị Dialog chỉnh sửa Avatar
  void _showEditAvatarDialog() {
    _avatarUrlController.text = _currentUserProfile?.photoURL ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật URL Avatar'),
          content: TextField(
            controller: _avatarUrlController,
            decoration: const InputDecoration(
              labelText: 'Đường dẫn (URL) ảnh mới',
              hintText: 'Ví dụ: https://example.com/avatar.jpg',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu URL'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveProfile();
              },
            ),
          ],
        );
      },
    );
  }

  // (THÊM) Hàm lưu Profile
  Future<void> _saveProfile() async {
    if (_currentUserProfile == null ||
        _isSaving ||
        _currentUserProfile!.uid != widget.uid)
      return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final newDisplayName = _displayNameController.text.trim();
      final newPhoneNumber = _phoneNumberController.text.trim();
      final newPhotoURL = _avatarUrlController.text.trim();

      // --- (SỬA LỖI) ---
      // Lấy profile hiện tại làm cơ sở để không làm mất
      // các giá trị `email` và `createdAt` đã có.
      final updatedProfile = User(
        uid: _currentUserProfile!.uid,
        email: _currentUserProfile!.email, // <-- Giữ lại email cũ
        createdAt: _currentUserProfile!.createdAt, // <-- Giữ lại ngày tạo cũ
        // --- Chỉ cập nhật các giá trị mới ---
        displayName: newDisplayName,
        phoneNumber: newPhoneNumber,
        photoURL: newPhotoURL.isEmpty ? null : newPhotoURL,
      );
      // --- (KẾT THÚC SỬA LỖI) ---

      final currentUserAuth = _auth.currentUser;
      if (currentUserAuth != null && currentUserAuth.uid == widget.uid) {
        await currentUserAuth.updateDisplayName(newDisplayName);
        await currentUserAuth.updatePhotoURL(
          newPhotoURL.isEmpty ? null : newPhotoURL,
        );
      }

      // (GIỮ NGUYÊN) Sử dụng _updateUserProfile (đã khởi tạo trong initState)
      await _updateUserProfile(updatedProfile);

      if (!mounted) return;
      setState(() {
        _currentUserProfile = updatedProfile;
        _isSaving = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu Thay Đổi Profile thành công!')),
        );
      });
    } on fb.FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lỗi Firebase: ${e.message}';
        _isSaving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lỗi lưu Profile: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  // (THAY THẾ) Toàn bộ hàm build được cập nhật lên UI mới
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final photoUrl = _currentUserProfile?.photoURL;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Profile'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Giao diện CHỈNH SỬA AVATAR
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isSaving ? null : _showEditAvatarDialog,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.link,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (_isSaving)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Thông tin cá nhân",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),

            // Trường Tên hiển thị
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: "Tên hiển thị",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Trường Số điện thoại
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Nút Lưu Thay Đổi Profile
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? "Đang lưu..." : "Lưu Thay Đổi Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Hiển thị lỗi (nếu có)
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            // THAY ĐỔI MẬT KHẨU
            const SizedBox(height: 40),
            const Text(
              "Thay đổi Mật khẩu (Auth)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),

            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu hiện tại",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Mật khẩu mới (Tối thiểu 6 ký tự)",
                prefixIcon: Icon(Icons.lock_reset),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Nút Đổi Mật khẩu
            ElevatedButton(
              onPressed: () {
                // Triển khai logic đổi mật khẩu
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Đổi Mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
