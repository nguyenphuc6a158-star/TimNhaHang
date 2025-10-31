// ignore_for_file: deprecated_member_use, unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/app_routes.dart';

// (MỚI) Imports cho Provider
import 'package:provider/provider.dart';
import 'package:timnhahang/core/providers/theme_provider.dart'; // Đảm bảo đường dẫn này đúng

class SettingPage extends StatefulWidget {
  final String uid;
  const SettingPage({super.key, required this.uid});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // Biến state
  User? _currentUserProfile;
  bool _isLoading = true;
  String? _errorMessage;
  // (ĐÃ XÓA) bool _isDarkMode = false; // Không cần state cục bộ nữa

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
        _errorMessage = 'Lỗi tải thông tin tài khoản: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToActivity() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Điều hướng đến trang Hoạt động...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy theme cho màu sắc
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      // === 1. AppBar ===
      appBar: AppBar(
        title: const Text('Tài khoản'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Sử dụng màu chính và một biến thể tối hơn của nó
              colors: [
                primaryColor,
                Color.lerp(primaryColor, Colors.black, 0.2)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // === 2. Body ===
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMenuBody(),
    );
  }

  Widget _buildMenuBody() {
    final photoUrl = _currentUserProfile?.photoURL;
    final displayName = _currentUserProfile?.displayName ?? "";

    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      // (CẬP NHẬT) Màu nền body nên dựa vào theme
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(245),
      child: ListView(
        children: [
          // --- 1. User Info Bar ---
          Container(
            color: Colors.black, // Thanh này giữ nguyên màu đen
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () =>
                        context.go('${AppRoutes.profile}/${widget.uid}'),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey[700],
                          backgroundImage:
                              (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
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
                InkWell(
                  onTap: _navigateToActivity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Xem hoạt động',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                          size: 20,
                        ),
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
              _buildMenuOption(
                Icons.payment,
                'Chi tiết tài khoản',
                Colors.blue.shade700,
                onTap: () => context.go('${AppRoutes.profile}/${widget.uid}'),
              ),
              _buildMenuOption(
                Icons.history,
                'Lịch sử',
                Colors.blue.shade700,
                onTap: () => context.go('${AppRoutes.history}/${widget.uid}'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 3. Nhóm 2 (Mời bạn bè, Góp ý) ---
          _buildSectionContainer(
            children: [
              _buildMenuOption(
                Icons.people_alt,
                'Mời bạn bè',
                Colors.orange.shade800,
              ),
              _buildMenuOption(
                Icons.email,
                'Góp ý',
                Colors.orange.shade800,
                hasDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // --- 4. Nhóm 3 (Chính sách, Cài đặt, Đăng xuất) ---
          _buildSectionContainer(
            children: [
              _buildMenuOption(
                Icons.policy,
                'Chính sách',
                Colors.grey.shade700,
              ),
              // (CẬP NHẬT) Kết nối Switch với ThemeProvider
              _buildSwitchOption(
                Icons.dark_mode,
                'Giao diện tối',
                Colors.grey.shade700,
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  // Dùng context.read khi gọi hàm, không cần lắng nghe
                  context.read<ThemeProvider>().setTheme(value);
                },
                hasDivider: true,
              ),
              _buildMenuOption(
                Icons.logout,
                'Đăng xuất',
                Colors.red.shade700, // Đổi màu cho nút Đăng xuất
                hasDivider: false,
                onTap: () => _auth.signOut(),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget chung cho các mục trong menu (ListTile)
  Widget _buildMenuOption(
    IconData icon,
    String title,
    Color iconColor, {
    bool hasDivider = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Đã bấm vào $title')));
          },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
                    // (CẬP NHẬT) Màu chữ nên dựa vào theme
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
              ],
            ),
          ),
          if (hasDivider)
            Divider(
              height: 1,
              thickness: 1,
              // (CẬP NHẬT) Màu đường kẻ nên dựa vào theme
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              indent: 56, // Căn lề cho đường kẻ
            ),
        ],
      ),
    );
  }

  // Widget chung cho các mục có nút Switch
  Widget _buildSwitchOption(
    IconData icon,
    String title,
    Color iconColor, {
    required bool value,
    required ValueChanged<bool> onChanged,
    bool hasDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                  // (CẬP NHẬT) Màu chữ nên dựa vào theme
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            thickness: 1,
            // (CẬP NHẬT) Màu đường kẻ nên dựa vào theme
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            indent: 56,
          ),
      ],
    );
  }

  // Widget chung cho các nhóm (Card)
  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        // (CẬP NHẬT) Màu nền của Card nên dựa vào theme
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            // (CẬP NHẬT) Màu đổ bóng nên dựa vào theme
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
