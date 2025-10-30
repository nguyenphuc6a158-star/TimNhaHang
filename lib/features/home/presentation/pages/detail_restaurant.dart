import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:timnhahang/features/comment/presentation/pages/comment_form_page.dart';
import 'package:timnhahang/features/comment/presentation/pages/comment_section.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:timnhahang/features/restaurantsave/data/data/restaurant_save_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/repositories/restaurant_save_repository_impl.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/add_saved_restaurant.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

// --- Widget Component: Hiển thị một dòng thông tin ---
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoRow({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          // Sử dụng Expanded để xử lý các chuỗi dài (như địa chỉ)
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  final UpdateRestaurant updateRestaurant;
  const DetailRestaurantPage({
    super.key,
    required this.restaurant,
    required this.updateRestaurant,
  });

  @override
  State<StatefulWidget> createState() => _DetailRestaurantPageState();

  void backPrePage(BuildContext context) {
    Navigator.pop(context);
  }
}

class _DetailRestaurantPageState extends State<DetailRestaurantPage> {
  late final _remote = RestaurantSaveRemoteDatasourceImpl();
  late final _repo = RestaurantSaveRepositoryImpl(_remote);
  late final _addSave = AddSavedRestaurant(_repo);

  late final _remoteDs = UsersRemoteDataSourceImpl();
  late final _repoUser = UserRepositoryImpl(_remoteDs);
  late final _getUser = GetUserProfile(_repoUser);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  User? _currentUserProfile;
  String? _errorMessage;
late ValueKey<int> _commentSectionKey = const ValueKey<int>(0);

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // (GIỮ NGUYÊN) Sử dụng _getUser (từ code gốc của bạn)
      final profile = await _getUser(uid);
      if (!mounted) return;
      setState(() {
        _currentUserProfile = profile; // Cập nhật state
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Lỗi tải: Tài khoản chưa có dữ liệu Profile. Vui lòng cập nhật.';
      });
    }
  }

  Future<void> _save() async {
    final newSave = Save(
      id: '',
      restaurantId: widget.restaurant.id,
      uid: uid,
      restaurantName: widget.restaurant.name,
      restaurantAddress: widget.restaurant.address,
      imageUrl: widget.restaurant.imageUrl,
      createdAt: DateTime.now(),
    );

    // 4. Gọi use case tương ứng
    try {
      await _addSave(newSave);
      if (mounted) {
        // Hiển thị thông báo thành công và quay lại trang trước
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product saved successfully!')));
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save product: $e')));
      }
    }
  }

  Future<void> _openCommentForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentFormPage(
          user: _currentUserProfile,
          restaurantId: widget.restaurant.id,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        // Tăng giá trị của Key (ví dụ: 0 -> 1)
        // Việc này buộc Flutter phải HỦY state cũ của CommentSection
        // và TẠO MỘT STATE MỚI, chạy lại initState và FutureBuilder!
        _commentSectionKey = ValueKey<int>(_commentSectionKey.value + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tính toán chiều cao ảnh
    final mediaQuery = MediaQuery.of(context);
    const primaryColor = Color(0xFF42A5F5); // Màu xanh dương nhạt
    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép body tràn lên phía sau AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            widget.backPrePage(context);
          },
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// 1. Image Header
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: mediaQuery.size.height * 0.35, // Chiếm 35% màn hình
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // Sử dụng imageUrl từ đối tượng restaurant
                      image: NetworkImage(widget.restaurant.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Lớp phủ để làm nổi bật tên nhà hàng và nút back
                Container(
                  height: mediaQuery.size.height * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                // Tên nhà hàng lớn ở phía dưới ảnh
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Text(
                    // Sử dụng name từ đối tượng restaurant
                    widget.restaurant.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),

            // 2. Nội dung chi tiết chính
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating & Review Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // Sử dụng rating từ đối tượng restaurant
                        '${widget.restaurant.rating.toString()} ⭐',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 3. Thông tin cơ bản (Address, Category, Price)
                  const Text(
                    'THÔNG TIN CHUNG',
                    style: TextStyle(
fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const Divider(height: 20),

                  // Sử dụng address từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.location_on,
                    label: widget.restaurant.address,
                  ),
                  // Sử dụng category từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.fastfood,
                    label: 'Thể loại: ${widget.restaurant.category}',
                  ),
                  // Sử dụng priceRange từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.attach_money,
                    label: 'Mức giá: ${widget.restaurant.priceRange}',
                  ),
                  // Sử dụng opening/closing từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.access_time,
                    label:
                        'Giờ mở cửa: ${widget.restaurant.opening} - ${widget.restaurant.closing}',
                  ),
                  const Divider(height: 30),

                  // 4. Các nút tương tác
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        Icons.comment,
                        'Bình luận',
                        primaryColor,
                        onTap: () => _openCommentForm(),
                      ),
                      _buildActionButton(
                        Icons.bookmark,
                        'Lưu lại',
                        primaryColor,
                        onTap: () => _save(),
                      ),
                    ],
                  ),
                  CommentSection(
                    key: _commentSectionKey, // Gán key vào đây
                    restaurantId: widget.restaurant.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            // Xử lý logic Đặt giao hàng tại đây
          },
          label: const Text('Đặt bàn'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildActionButton(
  IconData icon,
  String label,
  Color color, {
  VoidCallback? onTap, // Tên tham số vẫn là onTap, dễ hiểu
}) {
  // <<< THAY ĐỔI: Dùng TextButton >>>
  return TextButton(
    // <<< THAY ĐỔI: Dùng 'onPressed' thay vì 'onTap' >>>
    onPressed: onTap,

    // <<< THÊM MỚI: Dùng style để tùy chỉnh >>>
    style: TextButton.styleFrom(
      // 'foregroundColor' sẽ tự động áp dụng 'color' cho icon và chữ
      foregroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bo góc cho vùng nhấn
      ),
    ),
    child: Column(
      // Giữ cho Column co lại vừa đủ nội dung
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withOpacity(0.1),
          // Icon sẽ tự động lấy màu từ 'foregroundColor' ở trên
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          // Text cũng tự động lấy màu từ 'foregroundColor'
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}