import 'package:flutter/material.dart';
import 'package:timnhahang/features/comment/data/data/comment_remote_datasource.dart';
import 'package:timnhahang/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:timnhahang/features/comment/domain/entities/comment.dart';
import 'package:timnhahang/features/comment/domain/usecase/add_comment.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

class CommentFormPage extends StatefulWidget {
  final User? user;
  final String restaurantId; // Đổi từ AddProduct -> AddComment

  const CommentFormPage({
    super.key,
    required this.user,
    required this.restaurantId,
  });

  @override
  State<StatefulWidget> createState() => _CommentFormPageState();
}

class _CommentFormPageState extends State<CommentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final _remote = CommentRemoteDatasourceImpl();
  late final _repo = CommentRepositoryImpl(_remote);
  late final _addComment = AddComment(_repo);

  // --- 3. THAY ĐỔI CONTROLLERS VÀ STATE ---
  late final _contentController = TextEditingController();
  late final _imageUrlController = TextEditingController();
  double _rating = 3.0; // Thêm state cho rating, mặc định 3 sao

  // (Bỏ initState vì không cần gán giá trị 'edit' nữa)

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // --- 4. VIẾT LẠI HOÀN TOÀN HÀM _save ---
  Future<void> _save() async {
    final content = _contentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final now = DateTime.now();

    // 2. Tạo đối tượng Comment mới
    final newComment = Comment(
      id: '', // Backend sẽ tạo ID
      restaurantId: widget.restaurantId,
      uid: widget.user!.uid,
      userImage: widget.user!.photoURL!,
      userName: widget.user!.displayName!,
      imageUrl: imageUrl, // từ controller
      content: content, // từ controller
      createdAt: now,
      rating: _rating, // từ state
    );

    // 3. Gọi use case tương ứng (chỉ còn 'add')
    try {
      _addComment(newComment);

      if (mounted) {
        // Hiển thị thông báo thành công và quay lại trang trước
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi bình luận thành công!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save comment: $e')));
      }
    }
  }

  // --- 5. VIẾT LẠI HOÀN TOÀN HÀM build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (Bạn có thể thêm drawer nếu muốn)
      // drawer: HomePageWithDrawer(),
      appBar: AppBar(
        title: const Text('Viết bình luận'), // Đổi tiêu đề
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Trường Rating (Slider) ---
              Text(
                'Đánh giá của bạn: ${_rating.toStringAsFixed(1)} sao',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 8, // Cho phép chọn 0.5 sao
                label: _rating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Trường Content (Bình luận) ---
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Bình luận (không bắt buộc)',
                  hintText: 'Chia sẻ trải nghiệm của bạn...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 5,
                // Không cần validator vì không bắt buộc
              ),
              const SizedBox(height: 16),

              // --- Trường Image URL ---
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Link hình ảnh (không bắt buộc)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
                // Không cần validator vì không bắt buộc
              ),
              const SizedBox(height: 24),

              // --- Nút Save ---
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.send_outlined), // Đổi icon
                label: const Text('Gửi bình luận'), // Đổi text
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
