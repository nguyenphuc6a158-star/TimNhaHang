import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
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
class DetailRestaurantPage extends StatelessWidget {
  final Restaurant restaurant;
  final UpdateRestaurant updateRestaurant;
  const DetailRestaurantPage({
    super.key,
    required this.restaurant,
    required this.updateRestaurant
    });
  void backPrePage (BuildContext context) {
    Navigator.pop(context);
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
            backPrePage(context);
          },
        ),
        actions: const [
        ],
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
                      image: NetworkImage(restaurant.imageUrl),
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
                    restaurant.name,
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
                        '${restaurant.rating.toString()} ⭐',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 3. Thông tin cơ bản (Address, Category, Price)
                  const Text('THÔNG TIN CHUNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
                  const Divider(height: 20),

                  // Sử dụng address từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.location_on,
                    label: restaurant.address,
                  ),
                  // Sử dụng category từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.fastfood,
                    label: 'Thể loại: ${restaurant.category}',
                  ),
                  // Sử dụng priceRange từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.attach_money,
                    label: 'Mức giá: ${restaurant.priceRange}',
                  ),
                  // Sử dụng opening/closing từ đối tượng restaurant
                  InfoRow(
                    icon: Icons.access_time,
                    label: 'Giờ mở cửa: ${restaurant.opening} - ${restaurant.closing}',
                  ),
                  const Divider(height: 30),

                  // 4. Các nút tương tác
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.comment, 'Bình luận', primaryColor),
                      _buildActionButton(Icons.bookmark, 'Lưu lại', primaryColor),
                    ],
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
          icon: const Icon(Icons.delivery_dining),
          label: const Text('Đặt giao hàng'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
  }

Widget _buildActionButton(IconData icon, String label, Color color) {
  return Column(
    children: [
      CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    ],
  );
}