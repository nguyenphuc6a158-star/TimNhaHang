import 'package:flutter/material.dart';
// Sử dụng Tiền tố 'fb' cho Firebase Auth
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String? error;
  bool _isLoggingIn = false;

  // Hàm đăng nhập bằng Email/Pass (đã sửa)
  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      error = null;
      _isLoggingIn = true; // Bắt đầu loading
    });

    try {
      // SỬ DỤNG TIỀN TỐ fb. cho FirebaseAuth
      // ignore: unused_local_variable
      final fb.UserCredential userCredential = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text,
          );
      // Đăng nhập thành công.
      if (mounted) {
        // Điều hướng đến trang chính
        context.go(AppRoutes.home); // Ví dụ: Điều hướng về trang Home
      }
    } on fb.FirebaseAuthException catch (e) {
      // SỬ DỤNG TIỀN TỐ fb.
      if (e.code == 'user-not-found') {
        setState(() => error = 'Không tìm thấy người dùng với email này.');
      } else if (e.code == 'wrong-password') {
        setState(() => error = 'Mật khẩu không chính xác.');
      } else if (e.code == 'invalid-email') {
        setState(() => error = 'Địa chỉ email không hợp lệ.');
      } else {
        setState(() => error = 'Đã xảy ra lỗi: ${e.message}');
      }
    } catch (e) {
      // (CẬP NHẬT) Lỗi chung
      setState(() => error = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
    } finally {
      // Luôn dừng loading
      setState(() => _isLoggingIn = false);
    }
  }

  // Hàm đăng nhập với Google
  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => error = null);
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
      ),
      body: Stack(
        children: [
          // Lớp 1: Ảnh nền
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop',
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
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
                  // Phần nội dung chính (scroll được)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 30),
                          const Text(
                            "Đăng Nhập hoặc Đăng Ký",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Nút Đăng nhập Gmail
                          ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: const FaIcon(
                              FontAwesomeIcons.google,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text("Đăng nhập với Gmail"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
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
                          ),
                          const SizedBox(height: 24),

                          // Text phân tách
                          const Text(
                            "Hoặc đăng nhập bằng tài khoản của bạn",
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
                                  color: Colors.red.withValues(alpha: 0.5),
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
                            controller: emailCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Địa chỉ Email của bạn",
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.2),
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
                            controller: passCtrl,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mật khẩu của bạn",
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nút Đăng nhập
                          ElevatedButton(
                            onPressed: _isLoggingIn ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
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
                            child: _isLoggingIn
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text("Đăng nhập"),
                          ),
                          const SizedBox(height: 16),

                          // Links: Đăng ký & Quên mật khẩu
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => context.go(AppRoutes.signup),
                                child: const Text(
                                  "Đăng ký",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Chuyển đến trang Quên mật khẩu
                                  //print("Chuyển đến trang Quên mật khẩu");
                                },
                                child: const Text(
                                  "Quên mật khẩu?",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Phần chân trang (luôn ở dưới cùng)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text.rich(
                      TextSpan(
                        text:
                            "Bằng cách đăng nhập hoặc đăng ký, bạn đồng ý với ",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Chính sách quy định của Letsfood",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
