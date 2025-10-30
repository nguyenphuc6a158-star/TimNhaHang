import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/comment/data/model/comment_model.dart';

abstract class CommentRemoteDatasource {
  Future<List<CommentModel>> getAllById(String restaurantId);
  Future<void> add(CommentModel comment);
}

class CommentRemoteDatasourceImpl implements CommentRemoteDatasource {
  final FirebaseRemoteDS<CommentModel> remoteDS;

  CommentRemoteDatasourceImpl()
    : remoteDS = FirebaseRemoteDS<CommentModel>(
        collectionName: 'comments',
        fromFirestore: (doc) => CommentModel.fromFirestore(doc),
        toFirestore: (model) => model.toJson(),
      );

  @override
  Future<void> add(CommentModel comment) async {
    await remoteDS.add(comment);
  }

  @override
  Future<List<CommentModel>> getAllById(String restaurantId) async {
    List<CommentModel> comments = [];
    comments = await remoteDS.getAllById('restaurantId', restaurantId);
    return comments;
  }
}
