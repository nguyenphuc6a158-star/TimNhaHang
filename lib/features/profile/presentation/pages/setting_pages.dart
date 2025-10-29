import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';

import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
// import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
// import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/app_routes.dart';

class SettingPage extends StatefulWidget {
  final String uid;
  const SettingPage({super.key, required this.uid});

  @override
  // ĐỔI TÊN: _ProfilePageState -> _SettingPageState
  State<SettingPage> createState() => _SettingPageState();
}

// ĐỔI TÊN: _ProfilePageState -> _SettingPageState
class _SettingPageState extends State<SettingPage> {
  // Biến state
  User? _currentUserProfile;
  bool _isLoading = true;
  String? _errorMessage;

  // Usecase
  late final GetUserProfile _getUserProfile;

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
    super.dispose();
  }

  void _initializeDependencies() {
    final remoteDataSource = UsersRemoteDataSourceImpl();
    final repository = UserRepositoryImpl(remoteDataSource);

    _getUserProfile = GetUserProfile(repository);
  }

  Future<void> _fetchUserProfile() async {
    final uid = widget.uid;
    try {
      final profile = await _getUserProfile(uid);
      if (!mounted) return;
      setState(() {
        _currentUserProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage ='Lỗi tải thông tin tài khoản: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  // (MỚI) Hàm điều hướng đến trang "Hoạt động"
  void _navigateToActivity() {
    // TODO: Thay thế bằng logic điều hướng thật
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Điều hướng đến trang Hoạt động...')),
    );
  }


  // (CẬP NHẬT) Hàm build UI chính
  @override
  Widget build(BuildContext context) {
    // Lấy theme cho màu sắc
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor; // Giả sử màu tím là primaryColor

    return Scaffold(
      // === 1. AppBar ===
      appBar: AppBar(
        title: const Text('Tài khoản'),
        centerTitle: false, // Trong ảnh, title không ở giữa
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          // Thêm gradient cho giống ảnh
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Colors.purple.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Xử lý tìm kiếm
            },
          ),
        ],
      ),

      // === 2. Body ===
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMenuBody(),

      // === 3. (ĐÃ XÓA) Bottom Navigation Bar ===
      // Toàn bộ phần bottomNavigationBar đã được xóa khỏi đây.

    );
  }

  // (CẬP NHẬT) Widget build phần body menu
  Widget _buildMenuBody() {
    final photoUrl = _currentUserProfile?.photoURL;
    final displayName = _currentUserProfile?.displayName ?? "";

    return Container(
      color: Colors.grey[200], // Màu nền xám nhạt cho toàn bộ body
      child: ListView(
        children: [
          // --- 1. User Info Bar (Đã cập nhật) ---
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // (MỚI) Nút 1: Bấm vào Avatar/Tên
                Expanded(
                  child: InkWell(
                    onTap: () => context.go('${AppRoutes.profile}/${widget.uid}'), // <-- Nút đi đến Edit Profile
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[700],
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Vẫn cần Expanded để đẩy nút "Xem hoạt động" sang phải
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // (MỚI) Nút 2: Bấm vào "Xem hoạt động"
                InkWell(
                  onTap: _navigateToActivity, // <-- Nút đi đến trang Hoạt động
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        const Text(
                          'Xem hoạt động',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --- 2. Nhóm 1 (Thanh toán, Lịch sử, ...) ---
          _buildSectionContainer(
            children: [
              _buildMenuOption(Icons.payment, 'Thanh toán', Colors.blue.shade700),
              _buildMenuOption(Icons.history, 'Lịch sử', Colors.blue.shade700),
              _buildMenuOption(Icons.card_giftcard, 'Tiền thưởng', Colors.blue.shade700),
              _buildMenuOption(Icons.local_offer, 'Voucher', Colors.blue.shade700),
              _buildMenuOption(Icons.delivery_dining, 'Giao hàng', Colors.blue.shade700, hasDivider: false),
            ],
          ),
          const SizedBox(height: 12),

          // --- 3. Nhóm 2 (Mời bạn bè, Góp ý) ---
          _buildSectionContainer(
            children: [
              _buildMenuOption(Icons.people_alt, 'Mời bạn bè', Colors.orange.shade800),
              _buildMenuOption(Icons.email, 'Góp ý', Colors.orange.shade800, hasDivider: false),
            ],
          ),
          const SizedBox(height: 12),

          // --- 4. Nhóm 3 (Chính sách, Cài đặt, Đăng xuất) ---
          _buildSectionContainer(
            children: [
              _buildMenuOption(Icons.policy, 'Chính sách', Colors.grey.shade700),
              _buildMenuOption(Icons.settings, 'Cài đặt', Colors.grey.shade700),
              _buildMenuOption(Icons.logout, 'Đăng xuất', Colors.grey.shade700, hasDivider: false, onTap: () => _auth.signOut()),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }


  // (MỚI) Widget chung cho các mục trong menu (ListTile)
  Widget _buildMenuOption(IconData icon, String title, Color iconColor, {bool hasDivider = true, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {
        // TODO: Xử lý khi bấm vào các mục menu khác
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã bấm vào $title')),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconColor,
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
              ],
            ),
          ),
          if (hasDivider)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFf0f0f0),
              indent: 56, // Căn lề cho đường kẻ
            ),
        ],
      ),
    );
  }

  // (MỚI) Widget chung cho các nhóm (Card)
  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        // Viền mờ nhẹ cho đẹp hơn
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}