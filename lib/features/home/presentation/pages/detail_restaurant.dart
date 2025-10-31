// ignore_for_file: deprecated_member_use, unused_field

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timnhahang/features/comment/presentation/pages/comment_form_page.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/home/presentation/pages/form_order.dart';
import 'package:timnhahang/features/home/presentation/widgets/detail/body_detail.dart';
import 'package:timnhahang/features/home/presentation/widgets/detail/bottom_navigator_navbar_detal.dart';
import 'package:timnhahang/features/profile/data/data/user_remote_datasource.dart';
import 'package:timnhahang/features/profile/data/repositories/user_repository_impl.dart';
import 'package:timnhahang/features/profile/domain/usecase/get_user_profile.dart';
import 'package:timnhahang/features/restaurantsave/data/data/restaurant_save_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/repositories/restaurant_save_repository_impl.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/add_saved_restaurant.dart';
import 'package:timnhahang/features/profile/domain/entities/user.dart';

class DetailRestaurantPage extends StatefulWidget {
  final Restaurant restaurant;
  final UpdateRestaurant updateRestaurant;
  const DetailRestaurantPage({
    super.key,
    required this.restaurant,
    required this.updateRestaurant,
  });

  @override
  State<StatefulWidget> createState() => _DetailRestaurantPageState();
}

class _DetailRestaurantPageState extends State<DetailRestaurantPage> {
  late final _remote = RestaurantSaveRemoteDatasourceImpl();
  late final _repo = RestaurantSaveRepositoryImpl(_remote);
  late final _addSave = AddSavedRestaurant(_repo);

  late final _remoteDs = UsersRemoteDataSourceImpl();
  late final _repoUser = UserRepositoryImpl(_remoteDs);
  late final _getUser = GetUserProfile(_repoUser);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  User? _currentUserProfile;
  String? _errorMessage;
  late ValueKey<int> _commentSectionKey = const ValueKey<int>(0);

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // (GIỮ NGUYÊN) Sử dụng _getUser (từ code gốc của bạn)
      final profile = await _getUser(uid);
      if (!mounted) return;
      setState(() {
        _currentUserProfile = profile; // Cập nhật state
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Lỗi tải: Tài khoản chưa có dữ liệu Profile. Vui lòng cập nhật.';
      });
    }
  }

  Future<void> _save() async {
    final newSave = Save(
      id: '',
      restaurantId: widget.restaurant.id,
      uid: uid,
      restaurantName: widget.restaurant.name,
      restaurantAddress: widget.restaurant.address,
      imageUrl: widget.restaurant.imageUrl,
      createdAt: DateTime.now(),
    );

    // 4. Gọi use case tương ứng
    try {
      await _addSave(newSave);
      if (mounted) {
        // Hiển thị thông báo thành công và quay lại trang trước
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product saved successfully!')));
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save product: $e')));
      }
    }
  }

  void openOrderForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderForm(resid: widget.restaurant.id, uid: uid),
      ),
    );
  }

  Future<void> _openCommentForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentFormPage(
          user: _currentUserProfile,
          restaurantId: widget.restaurant.id,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        // Tăng giá trị của Key (ví dụ: 0 -> 1)
        // Việc này buộc Flutter phải HỦY state cũ của CommentSection
        // và TẠO MỘT STATE MỚI, chạy lại initState và FutureBuilder!
        _commentSectionKey = ValueKey<int>(_commentSectionKey.value + 1);
      });
    }
  }

  Future<void> _onShare() async {
    // Tạo nội dung bạn muốn chia sẻ
    final String shareContent =
        "Gợi ý cho bạn nè!\n"
        "Nhà hàng: ${widget.restaurant.name}\n"
        "Địa chỉ: ${widget.restaurant.address}";

    // Gọi hàm Share.share
    await Share.share(shareContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Cho phép body tràn lên phía sau AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [],
      ),
      body: BodyDetail(
        restaurant: widget.restaurant,
        save: _save,
        openCommentForm: _openCommentForm,
        commentSectionKey: _commentSectionKey,
        share: _onShare,
      ),
      bottomNavigationBar: BottomNavigatorNavbarDetal(
        restaurantID: widget.restaurant.id,
        uId: uid,
      ),
    );
  }
}
