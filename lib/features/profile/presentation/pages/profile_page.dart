import 'package:flutter/material.dart';
import 'package:timnhahang/features/profile/presentation/controllers/profile_controller.dart';
import 'package:timnhahang/features/profile/presentation/widgets/profile_widgets.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid
  });
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController()..init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa Profile'), centerTitle: true),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Kiểm tra lỗi tải profile sau khi loading xong
          if (_controller.profile == null) {
            return const Center(
              child: Text('Lỗi: Không tải được hồ sơ người dùng. Vui lòng kiểm tra đăng nhập.'),
            );
          }

          // Hiển thị form profile
          return SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  profile: _controller.profile!,
                  onAvatarTap: () => _showAvatarDialog(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileForm(),
                      const SizedBox(height: 30),
                      _buildPasswordForm(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm _buildCreateProfile đã được loại bỏ

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.person, title: 'Thông tin'),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _controller.nameController,
          label: 'Tên hiển thị',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _controller.phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _controller.isSaving ? null : () => _controller.saveProfile(context),
            icon: _controller.isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_controller.isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(icon: Icons.lock, title: 'Đổi mật khẩu'),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _controller.currentPwdController,
          label: 'Mật khẩu hiện tại',
          icon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _controller.newPwdController,
          label: 'Mật khẩu mới (≥ 6 ký tự)',
          icon: Icons.lock_reset,
          obscureText: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _controller.isChangingPassword
                ? null
                : () => _controller.changePassword(context),
            icon: _controller.isChangingPassword
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                : const Icon(Icons.key),
            label: Text(_controller.isChangingPassword ? 'Đang đổi...' : 'Đổi mật khẩu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAvatarDialog() {
    final controller = TextEditingController(text: _controller.profile?.photoURL);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cập nhật Avatar'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'URL ảnh',
            prefixIcon: Icon(Icons.link),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.updateAvatar(context, controller.text);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
