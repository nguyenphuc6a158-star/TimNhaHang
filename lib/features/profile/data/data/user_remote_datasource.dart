import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/models/user_model.dart';

abstract class UsersRemoteDatasource {
  Future<UserModel?> getUser(String uid);
  Future<void> update(UserModel user);
  Future<void> delete(String uid);
  Future<void> add(UserModel user);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDatasource {
  final FirebaseRemoteDS<UserModel> _remoteSource;
  UsersRemoteDataSourceImpl() : _remoteSource = FirebaseRemoteDS<UserModel>(
    collectionName: 'users',
    fromFirestore: (doc) => UserModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<void> add(UserModel user) async {
    await _remoteSource.add(user);
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    UserModel? user = await _remoteSource.getById(uid);
    return user;
  }

  @override
  Future<void> update(UserModel user) async {
    await _remoteSource.update(user.uid.toString(), user);
  }

  @override
  Future<void> delete(String uid) async {
    await _remoteSource.delete(uid);
  }
}