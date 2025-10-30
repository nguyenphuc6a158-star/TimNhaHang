import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/model/save_model.dart';

abstract class RestaurantSaveRemoteDatasource {
  Future<List<SaveModel>> getAllByUid(String uid);
  Future<void> add(SaveModel save);
  Future<void> delete(String id);
}

class RestaurantSaveRemoteDatasourceImpl
    implements RestaurantSaveRemoteDatasource {
  final FirebaseRemoteDS<SaveModel> remoteDS;

  RestaurantSaveRemoteDatasourceImpl()
    : remoteDS = FirebaseRemoteDS<SaveModel>(
        collectionName: 'saves',
        fromFirestore: (doc) => SaveModel.fromFirestore(doc),
        toFirestore: (model) => model.toJson(),
      );

  @override
  Future<void> add(SaveModel save) async {
    await remoteDS.add(save);
  }

  @override
  Future<List<SaveModel>> getAllByUid(String uid) async {
    List<SaveModel> saves = [];
    saves = await remoteDS.getAllById('uid', uid);
    return saves;
  }

  @override
  Future<void> delete(String id) async {
    await remoteDS.delete(id);
  }
}