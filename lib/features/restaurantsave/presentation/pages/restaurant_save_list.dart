// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/home/presentation/pages/detail_restaurant.dart';
import 'package:timnhahang/features/restaurantsave/data/data/restaurant_save_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/repositories/restaurant_save_repository_impl.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/delete_saved_restaurant.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/get_saved_restaurants.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';
import 'package:timnhahang/features/restaurantsave/presentation/widget/body_list_save.dart';
import 'package:timnhahang/features/restaurantsave/presentation/widget/dialog_confirm.dart';

class RestaurantSaveListPage extends StatefulWidget {
  final String uid;

  const RestaurantSaveListPage({
    super.key,
    required this.uid, // Yêu cầu uid khi gọi widget này
  });

  @override
  State<RestaurantSaveListPage> createState() => _RestaurantSaveListPageState();
}

class _RestaurantSaveListPageState extends State<RestaurantSaveListPage> {
  // Use case (giữ nguyên)
  late final _remoteSave = RestaurantSaveRemoteDatasourceImpl();
  late final _repoSave = RestaurantSaveRepositoryImpl(_remoteSave);
  late final _getSave = GetSavedRestaurants(_repoSave);
  // Dòng này đã có, rất tốt
  late final _deleteSave = DeleteSavedRestaurant(_repoSave);

  late final _remoteRestaurant = RestaurantsRemoteDataSourceImpl();
  late final _repoRestaurant = RestaurantRepositoryImpl(_remoteRestaurant);
  late final _getRestaurant = GetRestaurant(_repoRestaurant);
  late final _updateRestaurant = UpdateRestaurant(_repoRestaurant);
  // Biến trạng thái (giữ nguyên)
  bool _isLoading = true;
  List<Save> _savedList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Hàm _loadSavedData (giữ nguyên)
  Future<void> _loadSavedData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await _getSave(widget.uid);
      if (mounted) {
        setState(() {
          _savedList = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // <<< THÊM MỚI: Hàm xử lý logic xóa >>>
  Future<void> _deleteItem(Save saveItem) async {
    // 1. Hiển thị hộp thoại xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DialogConfirm(saveItem: saveItem),
    );

    if (confirm != true) return;

    try {
      await _deleteSave(saveItem.id);

      // 4. Cập nhật UI: Xóa item khỏi danh sách
      setState(() {
        _savedList.remove(saveItem);
      });

      // 5. Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa "${saveItem.restaurantName}"'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 6. Xử lý nếu có lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openDetailRestaurant(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailRestaurantPage(
          restaurant: restaurant,
          updateRestaurant: _updateRestaurant,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đã Lưu'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BodyListSave(
        loadSavedData: _loadSavedData, 
        savedList: _savedList,
        deleteItem: _deleteItem,
        getRestaurant: _getRestaurant,
        openDetailRestaurant: _openDetailRestaurant,
      ),
    );
  }
}