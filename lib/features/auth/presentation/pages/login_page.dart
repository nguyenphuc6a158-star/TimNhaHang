import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// TODO: Đảm bảo bạn đã thêm package này vào file pubspec.yaml:
// dependencies:
//   font_awesome_flutter: ^10.7.0
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

  // Hàm đăng nhập bằng Email/Pass (từ code gốc của bạn)
  Future<void> _login() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() => error = null); // Xóa lỗi cũ
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      // Đăng nhập thành công, bạn có thể điều hướng tại đây
      // ví dụ: Navigator.of(context).pushReplacement(...);
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi
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
      setState(() => error = 'Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  // Hàm đăng nhập với Google (mới)
  Future<void> _signInWithGoogle() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();
    setState(() => error = null); // Xóa lỗi cũ nếu có

    // TODO: Viết logic đăng nhập Google tại đây
    // Bạn sẽ cần dùng package 'google_sign_in'
    print("Đăng nhập Google");

    // (Logic ví dụ)
    // try {
    //   // ... code đăng nhập Google ...
    // } catch (e) {
    //   setState(() => error = 'Đăng nhập Google thất bại.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cho phép body hiển thị đằng sau AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0, // Bỏ bóng mờ
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Lớp 1: Ảnh nền từ Internet
          Positioned.fill(
            child: Image.network(
              // Đây là ảnh ví dụ, bạn có thể thay bằng URL bất kỳ:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop',
              fit: BoxFit.cover,
              // Hiệu ứng mờ dần khi tải ảnh
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              // Hiển thị vòng xoay khi chờ tải ảnh
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              // Hiển thị icon lỗi nếu không tải được ảnh
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
            child: Container(
              // Bạn có thể tăng/giảm opacity để tăng độ tối
              color: Colors.black.withOpacity(0.45),
            ),
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
                          // Khoảng đệm để nội dung không bị AppBar che
                          SizedBox(height: 30),

                          // Tiêu đề
                          const Text(
                            "Đăng Nhập hoặc Đăng Ký",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20, // Chỉnh nhỏ lại một chút
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30), // Giảm khoảng cách
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
                              backgroundColor: const Color(
                                0xFFE53935,
                              ), // Màu đỏ
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
                                  color: Colors.red.withOpacity(0.2),
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
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
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
                                color: Colors.white.withOpacity(0.7),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Nút Đăng nhập (sử dụng hàm _login của bạn)
                          ElevatedButton(
                            onPressed: _login, // <-- Sử dụng hàm gốc
                            style: ElevatedButton.styleFrom(
                              // Bạn có thể đổi màu này
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
                            child: const Text("Đăng nhập"),
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
                                  // TODO: Chuyển đến trang Quên mật khẩu
                                  print("Chuyển đến trang Quên mật khẩu");
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
                            // Thêm recognizer nếu bạn muốn làm cho nó có thể nhấp được
                            // import 'package:flutter/gestures.dart';
                            // recognizer: TapGestureRecognizer()..onTap = () {
                            //   // TODO: Mở link chính sách
                            // },
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
