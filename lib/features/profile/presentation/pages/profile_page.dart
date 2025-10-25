import 'package:flutter/material.dart';
// Các Import cần thiết để "nối dây" và sử dụng Entity
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Biến để lưu trữ Usecase đã được khởi tạo
  late GetUserProfile getUserProfile;

  // Trạng thái của trang
  bool _isLoading = true;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDependenciesAndFetchData();
  }

  void _initializeDependenciesAndFetchData() {
    try {
      final String? uid = auth.FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        setState(() {
          _isLoading = false;
          _error = "Người dùng chưa đăng nhập. Vui lòng đăng nhập lại.";
        });
        return;
      }

      // Khởi tạo các thành phần (Nối dây thủ công)
      final firestore = FirebaseFirestore.instance;
      final remoteDataSource = UserRemoteDataSourceImpl(firestore: firestore);
      final repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);
      getUserProfile = GetUserProfile(repository); // Usecase đã sẵn sàng

      // Bắt đầu gọi Usecase
      _fetchData(uid);

    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Lỗi hệ thống: $e";
      });
    }
  }

  // Hàm gọi Usecase
  Future<void> _fetchData(String uid) async {
    try {
      final userResult = await getUserProfile.call(uid); // Gọi Usecase

      setState(() {
        _user = userResult;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().contains('User profile not found')
            ? 'Tài khoản chưa có dữ liệu Profile. Vui lòng cập nhật.'
            : 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
      ),
      body: Center(
        child: _buildBody(), // Gọi hàm xây dựng giao diện theo trạng thái
      ),
    );
  }

  // Xây dựng giao diện theo trạng thái
  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'Lỗi: $_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (_user != null) {
      return _buildProfileView(_user!);
    }

    return const Text('Không thể tải dữ liệu người dùng.');
  }

  // Giao diện hiển thị dữ liệu thật
  Widget _buildProfileView(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: (user.photoURL.isNotEmpty)
                ? NetworkImage(user.photoURL)
                : null,
            child: (user.photoURL.isEmpty && user.displayName.isNotEmpty)
                ? Text(user.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 30))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName.isNotEmpty ? user.displayName : 'Chưa cập nhật tên',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Số điện thoại'),
            subtitle: Text(
              user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Chưa cập nhật',
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Chỉnh sửa Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Điều hướng đến trang chỉnh sửa
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.FirebaseAuth.instance.signOut();
              // TODO: Điều hướng về trang Login
            },
          ),
        ],
      ),
    );
  }
}