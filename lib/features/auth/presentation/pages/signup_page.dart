import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb; // Thêm 'as fb'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Thêm GoRouter để điều hướng
import 'package:timnhahang/core/routing/app_routes.dart'; // Thêm AppRoutesS
import 'package:timnhahang/features/profile/domain/usecase/create_user_profile.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final confirmPasswordCtr =
      TextEditingController(); // Thêm controller cho xác nhận
  String? error;
  bool _isRegistering = false; // (MỚI) Thêm trạng thái loading

  // (MỚI) Khai báo Usecase
  late final CreateUserProfile createProfileUseCase;

  // (MỚI) Thêm initState để chuẩn bị UseCase
  @override
  void initState() {
    super.initState();
    // Nối dây (DI) các Usecase cần thiết cho Profile (Giống LoginPage)
    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = UserRemoteDataSourceImpl(firestore: firestore);
    final repository = UserRepositoryImpl(remoteDataSource: remoteDataSource);

    createProfileUseCase = CreateUserProfile(repository);
  }

  // (ĐÃ CẬP NHẬT) Hàm đăng ký
  Future<void> _register() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();
    setState(() {
      error = null;
      _isRegistering = true; // Bắt đầu loading
    });

    // 1. Kiểm tra mật khẩu có khớp không
    if (passwordCtr.text != confirmPasswordCtr.text) {
      setState(() {
        error = "Mật khẩu xác nhận không khớp.";
        _isRegistering = false; // Dừng loading
      });
      return;
    }

    // 2. Nếu khớp, tiến hành đăng ký
    try {
      // (CẬP NHẬT) Sử dụng tiền tố 'fb.'
      final fb.UserCredential userCredential = await fb.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtr.text.trim(),
            password: passwordCtr.text,
          );

      // --- (PHẦN MỚI) TẠO PROFILE NGAY LẬP TỨC ---
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final email = userCredential.user!.email!;
        // Lấy photoURL (thường là null khi đăng ký email/pass)
        final photoUrl = userCredential.user!.photoURL;

        // Tạo đối tượng User entity
        final User initialProfile = User(
          uid: uid,
          email: email,
          displayName: '', // Mặc định là rỗng
          photoURL: photoUrl ?? '', // Mặc định là rỗng
          phoneNumber: '', // Mặc định là rỗng
          createdAt: Timestamp.now(), // Thời điểm tạo
        );

        // Gọi Usecase để lưu vào Firestore
        await createProfileUseCase.call(initialProfile);
      }
      // --- KẾT THÚC PHẦN MỚI ---

      // Đăng ký thành công, chuyển đến trang chủ (thay vì pop)
      if (mounted) {
        // Thay vì pop(), chúng ta điều hướng đến Home
        // Người dùng đã đăng ký và đăng nhập
        context.go(AppRoutes.home);
      }
    } on fb.FirebaseAuthException catch (e) {
      // (CẬP NHẬT) Sử dụng tiền tố 'fb.'
      // Xử lý lỗi từ Firebase
      if (e.code == 'weak-password') {
        setState(() => error = 'Mật khẩu quá yếu (ít nhất 6 ký tự).');
      } else if (e.code == 'email-already-in-use') {
        setState(() => error = 'Email này đã được sử dụng.');
      } else if (e.code == 'invalid-email') {
        setState(() => error = 'Địa chỉ email không hợp lệ.');
      } else {
        setState(() => error = 'Đã xảy ra lỗi: ${e.message}');
      }
    } catch (e) {
      // Bắt cả lỗi khi tạo profile
      setState(() => error = 'Đã xảy ra lỗi. (Lỗi Profile: $e)');
    } finally {
      // (MỚI) Luôn dừng loading
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Đăng Ký",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Lớp 1: Ảnh nền từ Internet
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
          // Lớp 2: Lớp phủ mờ tối
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          // Lớp 3: Nội dung trang
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Khoảng đệm cho AppBar
                          SizedBox(height: 30),
                          const SizedBox(height: 30),
                          // Text phân tách
                          const Text(
                            "Đăng ký bằng email của bạn",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Hiển thị lỗi (nếu có)
                          if (error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(
                                    alpha: 0.5,
                                  ), // Sửa
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          // Trường Email
                          TextField(
                            controller: emailCtr, // Sửa: controller
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Địa chỉ Email của bạn",
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.2,
                              ), // Sửa
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Trường Mật khẩu
                          TextField(
                            controller: passwordCtr, // Sửa: controller
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mật khẩu (ít nhất 6 ký tự)", // Thêm
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.2,
                              ), // Sửa
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Trường Xác nhận Mật khẩu
                          TextField(
                            controller: confirmPasswordCtr, // Sửa: controller
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Xác nhận mật khẩu",
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white.withValues(
                                  alpha: 0.7,
                                ), // Sửa
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(
                                alpha: 0.2,
                              ), // Sửa
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nút Đăng ký (ĐÃ CẬP NHẬT)
                          ElevatedButton(
                            onPressed: _isRegistering
                                ? null
                                : _register, // Sử dụng hàm đăng ký
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurpleAccent, // Màu tím
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // (CẬP NHẬT) Hiển thị loading
                            child: _isRegistering
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text("Đăng Ký"),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Phần chân trang (quay lại Đăng nhập)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Đã có tài khoản?",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Đăng nhập ngay",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
