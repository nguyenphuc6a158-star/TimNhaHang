import 'package:flutter/material.dart';
import 'package:timnhahang/features/comment/data/data/comment_remote_datasource.dart';
import 'package:timnhahang/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:timnhahang/features/comment/domain/entities/comment.dart';
import 'package:timnhahang/features/comment/domain/usecase/get_all_comment.dart';

class CommentSection extends StatefulWidget {
  final String restaurantId;

  const CommentSection({super.key, required this.restaurantId});

  @override
  State<StatefulWidget> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late final _remote = CommentRemoteDatasourceImpl();
  late final _repo = CommentRepositoryImpl(_remote);
  late final _getComment = GetAllComment(_repo);

  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _getComment(widget.restaurantId);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF42A5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ĐÁNH GIÁ & BÌNH LUẬN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleSmall?.color,
          ),
        ),
        const Divider(height: 1),
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Lỗi tải bình luận: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              final comments = snapshot.data!;

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

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return _buildCommentItem(comment);
                },
              );
            }
            return const Center(child: Text('Đang tải...'));
          },
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Xem tất cả bình luận',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final String date =
        "${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year}";

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
          CircleAvatar(
            radius: 20,
            backgroundImage: comment.userImage.isNotEmpty
                ? NetworkImage(comment.userImage)
                : null,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
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
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                _buildCommentImage(comment.imageUrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentImage(String imageUrl) {
    // Nếu không có ảnh, trả về một widget rỗng
    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      // ignore: sized_box_for_whitespace
      child: Container(
        height: 150,
        width: 250,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              // Container này sẽ tự động lấp đầy
              return Container(
                color: Theme.of(context).hoverColor.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Container này cũng sẽ tự động lấp đầy
              return Container(
                color: Theme.of(context).hoverColor.withValues(alpha: 0.5),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
