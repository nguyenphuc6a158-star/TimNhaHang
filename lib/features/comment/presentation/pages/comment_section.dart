// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:timnhahang/features/comment/data/data/comment_remote_datasource.dart';
import 'package:timnhahang/features/comment/data/repositories/comment_repository_impl.dart';
// --- THÊM MỚI: Import entity 'Comment' ---
import 'package:timnhahang/features/comment/domain/entities/comment.dart';
import 'package:timnhahang/features/comment/domain/usecase/get_all_comment.dart';

class CommentSection extends StatefulWidget {
  final String restaurantId;

  // --- THAY ĐỔI: Sửa lại constructor (tôi bỏ 'primaryColor' đi để cho gọn) ---
  const CommentSection({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late final _remote = CommentRemoteDatasourceImpl();
  late final _repo = CommentRepositoryImpl(_remote);
  late final _getComment = GetAllComment(_repo);

  // --- THÊM MỚI: Biến để giữ 'Future' của danh sách bình luận ---
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    // --- THÊM MỚI: Gọi use case MỘT LẦN khi widget được tạo ---
    _commentsFuture = _getComment(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    // --- THÊM MỚI: Định nghĩa 'primaryColor' cục bộ để sửa lỗi ---
    // (Bạn có thể thay đổi màu này nếu muốn)
    const primaryColor = Color(0xFF42A5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ĐÁNH GIÁ & BÌNH LUẬN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const Divider(height: 1),

        // --- THAY THẾ: Dùng FutureBuilder thay vì code mẫu ---
        FutureBuilder<List<Comment>>(
          future: _commentsFuture, // Sử dụng Future đã gọi trong initState
          builder: (context, snapshot) {
            // 1. Trường hợp đang tải
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // 2. Trường hợp có lỗi
            if (snapshot.hasError) {
              return Center(
                child: Text('Lỗi tải bình luận: ${snapshot.error}'),
              );
            }

            // 3. Trường hợp có dữ liệu
            if (snapshot.hasData) {
              final comments = snapshot.data!;

              // 3a. Trường hợp không có bình luận nào
              if (comments.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Chưa có bình luận nào.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                );
              }

              // 3b. Hiển thị danh sách bình luận
              return ListView.builder(
                shrinkWrap: true, // Quan trọng: để ListView co lại trong Column
                physics:
                    const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của ListView
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  // Gọi hàm _buildCommentItem với object 'comment'
                  return _buildCommentItem(comment);
                },
              );
            }

            // 4. Trường hợp mặc định (ít khi xảy ra)
            return const Center(child: Text('Đang tải...'));
          },
        ),

        // --- KẾT THÚC THAY THẾ ---
        const SizedBox(height: 10),

        // Nút xem tất cả bình luận
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Xem tất cả bình luận',
              style: TextStyle(
                color: primaryColor, // Sử dụng màu đã định nghĩa ở trên
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// --- THAY ĐỔI: Hàm này giờ nhận vào một object 'Comment' ---
  Widget _buildCommentItem(Comment comment) {
    // Định dạng ngày tháng (ví dụ: 30/10/2025)
    final String date =
        "${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}";

    // Hàm buildStars (giữ nguyên như cũ)
    List<Widget> buildStars(double rating) {
      List<Widget> stars = [];
      int fullStars = rating.floor();
      bool hasHalfStar = (rating - fullStars) >= 0.5;

      for (int i = 0; i < fullStars; i++) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: 16));
      }
      if (hasHalfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: 16));
      }
      int emptyStars = 5 - (fullStars + (hasHalfStar ? 1 : 0));
      for (int i = 0; i < emptyStars; i++) {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
      return stars;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- THAY ĐỔI: Xử lý 'userImage' (String non-nullable) ---
          CircleAvatar(
            radius: 20,
            // Nếu 'userImage' không rỗng, thì hiển thị NetworkImage
            backgroundImage: comment.userImage.isNotEmpty
                ? NetworkImage(comment.userImage)
                : null,
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            // Nếu 'userImage' rỗng, thì hiển thị chữ cái đầu của tên
            child: comment.userImage.isEmpty
                ? Text(
                    comment.userName.isNotEmpty
                        ? comment.userName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null, // Ngược lại thì không hiển thị child
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...buildStars(comment.rating),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
