import 'package:timnhahang/features/comment/domain/entities/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getCommentById(String restaurantId);
  Future<void> createComment(Comment comment);
}
