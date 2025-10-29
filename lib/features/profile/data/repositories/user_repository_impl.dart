

import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/models/user_model.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl extends UserRepository {
  final UsersRemoteDatasource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createUser(User user) async {
    await remoteDataSource.add(UserModel.fromEntity(user));
  }

  @override
  Future<void> deleteUser(String uid) async {
    await remoteDataSource.delete(uid);
  }

  @override
  Future<User> getUser(String uid) async {
    UserModel? userModel = await remoteDataSource.getUser(uid);
    if (userModel == null) {
      throw Exception('Note not found');
    }
    return userModel;
  }
  @override
  Future<void> updateUser(User user) async {
    await remoteDataSource.update(UserModel.fromEntity(user));
  }

}