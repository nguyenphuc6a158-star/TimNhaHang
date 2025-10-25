import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
// Xóa import Firebase Storage và Image Picker
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

// Import Profile dependencies
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:timnhahang/features/profile/domain/usecase/update_user_profile.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Biến state
  User? _currentUserProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Controllers
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _avatarUrlController = TextEditingController(); // Controller mới cho URL Avatar

  // Usecase (Giả định khởi tạo đơn giản)
  late final GetUserProfile _getUserProfile;
  late final UpdateUserProfile _updateUserProfile;

  // Firebase Services
  final _auth = fb.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _initializeDependencies() {
    // Khởi tạo Firestore instance
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = UserRemoteDataSourceImpl(firestore: firestore);
    final repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);

    _getUserProfile = GetUserProfile(repository);
    _updateUserProfile = UpdateUserProfile(repository);
  }

  // Tải Profile của người dùng hiện tại
  Future<void> _fetchUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _errorMessage = 'Người dùng chưa đăng nhập.';
        _isLoading = false;
      });
      return;
    }

    try {
      final profile = await _getUserProfile.call(uid);
      setState(() {
        _currentUserProfile = profile;
        _displayNameController.text = profile.displayName ?? '';
        _phoneNumberController.text = profile.phoneNumber ?? '';
        // Đặt URL Avatar hiện tại vào controller
        _avatarUrlController.text = profile.photoURL ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Lỗi này thường xảy ra nếu Profile chưa có trên Firestore
        _errorMessage = 'Lỗi tải: Tài khoản chưa có dữ liệu Profile. Vui lòng cập nhật.';
        _isLoading = false;
      });
    }
  }

  // HỘP THOẠI NHẬP URL AVATAR MỚI
  void _showEditAvatarDialog() {
    // Đặt URL hiện tại vào controller trước khi mở dialog
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
                // Kích hoạt hàm lưu Profile để áp dụng thay đổi URL
                _saveProfile();
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm lưu thông tin Name/Phone VÀ Photo URL
  Future<void> _saveProfile() async {
    if (_currentUserProfile == null || _isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final newDisplayName = _displayNameController.text.trim();
      final newPhoneNumber = _phoneNumberController.text.trim();
      final newPhotoURL = _avatarUrlController.text.trim(); // Lấy URL từ controller

      // 1. Cập nhật Profile Entity trên Firestore (Sử dụng copyWith)
      final updatedProfile = _currentUserProfile!.copyWith(
        displayName: newDisplayName,
        phoneNumber: newPhoneNumber,
        photoURL: newPhotoURL.isEmpty ? null : newPhotoURL, // Lưu URL mới
      );

      // 2. Đồng bộ Tên hiển thị VÀ Photo URL với Auth User
      await _auth.currentUser!.updateDisplayName(newDisplayName);
      await _auth.currentUser!.updatePhotoURL(newPhotoURL.isEmpty ? null : newPhotoURL);


      await _updateUserProfile.call(updatedProfile);

      setState(() {
        _currentUserProfile = updatedProfile;
        _isSaving = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu Thay Đổi Profile thành công!')),
        );
      });

    } on fb.FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Lỗi Firebase: ${e.message}';
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi lưu Profile: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _currentUserProfile == null) {
      // Trường hợp Profile không tồn tại trên Firestore
      return Scaffold(
        appBar: AppBar(title: const Text('Tạo Profile')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Nút chuyển hướng người dùng đến màn hình tạo Profile (hoặc tự động tạo)
                ElevatedButton(
                  onPressed: () {
                    // Tạm thời cho phép người dùng nhập thông tin và lưu, tạo Profile mới
                    // Khi _currentUserProfile == null, người dùng cần tạo Profile
                    _currentUserProfile = User(
                      uid: _auth.currentUser!.uid,
                      email: _auth.currentUser!.email!,
                      createdAt: Timestamp.now(),
                      // Lấy sẵn photoURL và displayName từ Auth user
                      photoURL: _auth.currentUser!.photoURL,
                      displayName: _auth.currentUser!.displayName,
                    );
                    _displayNameController.text = _currentUserProfile!.displayName ?? '';
                    _avatarUrlController.text = _currentUserProfile!.photoURL ?? '';

                    _isLoading = false; // Tắt loading
                    _errorMessage = null; // Xóa lỗi
                    setState(() {}); // Kích hoạt build lại để hiển thị form
                  },
                  child: const Text('Bắt đầu cập nhật Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Nếu _currentUserProfile != null
    final photoUrl = _currentUserProfile!.photoURL;
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
                    // Sử dụng NetworkImage nếu có photoUrl hợp lệ
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    )
                        : null,
                  ),
                  // NÚT MỞ HỘP THOẠI NHẬP URL
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
                          Icons.link, // Thay icon camera bằng icon link
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

            // Các trường mật khẩu
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
                // TODO: Triển khai logic đổi mật khẩu sử dụng Firebase Auth
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
