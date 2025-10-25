import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/repositories/user_repository.dart';
import 'package:timnhahang/features/profile/data/models/user_model.dart'; // Cần để chuyển đổi ngược lại

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getUserProfile(String uid) async {
    // Gọi DataSource để lấy UserModel
    final userModel = await remoteDataSource.getUserProfile(uid);
    // Trả về Entity (User) cho lớp Domain
    return userModel;
  }

  @override
  Future<void> updateProfile(User user) async {
    // Chuyển Entity (User) thành Model (UserModel) để có hàm toMap()
    // Lưu ý: Nếu user không phải UserModel, bạn phải tạo UserModel thủ công từ User
    final userModel = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
    );
    await remoteDataSource.updateProfile(userModel);
  }
  @override
  Future<void> createProfile(User user) async {
    // Chuyển Entity sang Model
    final userModel = UserModel(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
    );
    await remoteDataSource.createProfile(userModel);
  }
}