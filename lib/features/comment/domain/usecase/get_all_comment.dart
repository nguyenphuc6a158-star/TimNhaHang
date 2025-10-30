import 'package:timnhahang/features/comment/domain/entities/comment.dart';
import 'package:timnhahang/features/comment/domain/repositories/comment_repository.dart';

class GetAllComment {
  final CommentRepository commentRepository;

  GetAllComment(this.commentRepository);

  Future<List<Comment>> call(String restaurantId) {
    return commentRepository.getCommentById(restaurantId);
  }
}
