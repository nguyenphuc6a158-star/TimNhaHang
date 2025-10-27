import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<void> _register() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();
    setState(() => error = null);

    // 1. Kiểm tra mật khẩu có khớp không
    if (passwordCtr.text != confirmPasswordCtr.text) {
      setState(() => error = "Mật khẩu xác nhận không khớp.");
      return;
    }

    // 2. Nếu khớp, tiến hành đăng ký
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtr.text.trim(),
        password: passwordCtr.text,
      );
      // Đăng ký thành công, tự động quay lại (hoặc chuyển đến trang chủ)
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi từ Firebase
      if (e.code == 'weak-password') {
        setState(() => error = 'Mật khẩu quá yếu.');
      } else if (e.code == 'email-already-in-use') {
        setState(() => error = 'Email này đã được sử dụng.');
      } else if (e.code == 'invalid-email') {
        setState(() => error = 'Địa chỉ email không hợp lệ.');
      } else {
        setState(() => error = 'Đã xảy ra lỗi: ${e.message}');
      }
    } catch (e) {
      setState(() => error = 'Đã xảy ra lỗi. Vui lòng thử lại.');
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
              // Sử dụng cùng một ảnh nền hoặc một ảnh khác
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop',
              fit: BoxFit.cover,
              // Hiển thị vòng xoay khi chờ tải ảnh
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
                                  color: Colors.red.withValues(alpha: 0.2),
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
                            controller: passwordCtr, // Sửa: controller
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Mật khẩu",
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
                          const SizedBox(height: 16),

                          // Trường Xác nhận Mật khẩu
                          TextField(
                            controller: confirmPasswordCtr, // Sửa: controller
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Xác nhận mật khẩu",
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
                          const SizedBox(height: 24),

                          // Nút Đăng ký
                          ElevatedButton(
                            onPressed: _register, // Sử dụng hàm đăng ký
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
                            child: const Text("Đăng Ký"),
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
