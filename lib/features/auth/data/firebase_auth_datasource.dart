import 'package:firebase_auth/firebase_auth.dart';
import 'package:timnhahang/features/auth/domain/entities/user_entity.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDatasource(this._firebaseAuth);

  Future<UserEntity?> signIn(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _userFromFirebase(cred.user);
  }

  Future<UserEntity?> signUp(String email, String password) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return _userFromFirebase(cred.user);
  }

  Future<void> signOut() async => _firebaseAuth.signOut();

  UserEntity? _userFromFirebase(User? user) {
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email);
  }
}
