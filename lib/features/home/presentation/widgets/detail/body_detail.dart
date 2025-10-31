// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:timnhahang/features/comment/presentation/pages/comment_section.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/presentation/widgets/detail/build_action_button.dart';
import 'package:timnhahang/features/home/presentation/widgets/detail/infor_row.dart';

class BodyDetail extends StatelessWidget {
  final Restaurant restaurant;
  final Future<void> Function() save;
  final Future<void> Function() openCommentForm;
  final Future<void> Function() share;
  final ValueKey<int> commentSectionKey;
  const BodyDetail({
    super.key,
    required this.restaurant,
    required this.save,
    required this.share,
    required this.openCommentForm,
    required this.commentSectionKey,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: mediaQuery.size.height * 0.35, // Chiếm 35% màn hình
                decoration: BoxDecoration(
                  image: DecorationImage(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${restaurant.rating.toString()} ⭐',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'THÔNG TIN CHUNG',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const Divider(height: 20),
                InfoRow(icon: Icons.location_on, label: restaurant.address),
                InfoRow(
                  icon: Icons.fastfood,
                  label: 'Thể loại: ${restaurant.category}',
                ),
                InfoRow(
                  icon: Icons.attach_money,
                  label: 'Mức giá: ${restaurant.priceRange}',
                ),
                InfoRow(
                  icon: Icons.access_time,
                  label:
                      'Giờ mở cửa: ${restaurant.opening} - ${restaurant.closing}',
                ),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    BuildActionButton(
                      icon: Icons.comment,
                      label: 'Bình luận',
                      color: Color(0xFF42A5F5),
                      onTap: () => openCommentForm(),
                    ),
                    BuildActionButton(
                      icon: Icons.bookmark,
                      label: 'Lưu lại',
                      color: Color(0xFF42A5F5),
                      onTap: () => save(),
                    ),
                    BuildActionButton(
                      icon: Icons.share,
                      label: 'Chia sẻ',
                      color: Color(0xFF4CAF50), // Màu xanh lá
                      onTap: () => share(),
                    ),
                  ],
                ),
                CommentSection(
                  key: commentSectionKey, // Gán key vào đây
                  restaurantId: restaurant.id,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
