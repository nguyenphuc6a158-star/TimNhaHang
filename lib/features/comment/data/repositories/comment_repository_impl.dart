import 'package:timnhahang/features/comment/data/data/comment_remote_datasource.dart';
import 'package:timnhahang/features/comment/data/model/comment_model.dart';
import 'package:timnhahang/features/comment/domain/entities/comment.dart';
import 'package:timnhahang/features/comment/domain/repositories/comment_repository.dart';

class CommentRepositoryImpl extends CommentRepository {
  final CommentRemoteDatasource commentRemoteDatasource;

  CommentRepositoryImpl(this.commentRemoteDatasource);

  @override
  Future<void> createComment(Comment comment) async {
    CommentModel commentModel = CommentModel.fromEntity(comment);
    await commentRemoteDatasource.add(commentModel);
  }

  @override
  Future<List<Comment>> getCommentById(String restaurantId) async {
    List<CommentModel> comments = await commentRemoteDatasource.getAllById(
      restaurantId,
    );
    return comments;
  }
}
