import 'package:flutter/material.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid
  });
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UsersRemoteDataSourceImpl _remote = UsersRemoteDataSourceImpl();
  late final UserRepositoryImpl _repo = UserRepositoryImpl(_remote);
  late final GetUserProfile _getUser = GetUserProfile(_repo);
  User? user;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  Future<void> _loadUser() async {
    final result = await _getUser(widget.uid);
    setState(() {
      user = result;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(user?.displayName ?? ''),
    );
  }
}