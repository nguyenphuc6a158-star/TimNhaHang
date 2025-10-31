// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:timnhahang/features/restaurantsave/data/data/restaurant_save_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/repositories/restaurant_save_repository_impl.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/delete_saved_restaurant.dart';
import 'package:timnhahang/features/restaurantsave/domain/usecase/get_saved_restaurants.dart';
// <<< THÊM MỚI: Import entity 'Save' của bạn >>>
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';

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
  late final _remote = RestaurantSaveRemoteDatasourceImpl();
  late final _repo = RestaurantSaveRepositoryImpl(_remote);
  late final _getSave = GetSavedRestaurants(_repo);
  // Dòng này đã có, rất tốt
  late final _deleteSave = DeleteSavedRestaurant(_repo);

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
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn bỏ lưu nhà hàng "${saveItem.restaurantName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
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

  // Hàm _buildBody (Cập nhật bên trong ListView.builder)
  Widget _buildBody() {
    // ... (Các trạng thái loading, error, empty giữ nguyên) ...

    // 4. Hiển thị danh sách
    return RefreshIndicator(
      onRefresh: _loadSavedData,
      child: ListView.builder(
        itemCount: _savedList.length,
        itemBuilder: (context, index) {
          final saveItem = _savedList[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              // ... (leading, title, subtitle giữ nguyên) ...
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  saveItem.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              title: Text(
                saveItem.restaurantName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Đã lưu: ${saveItem.createdAt.toLocal().toString().split(' ')[0]}',
              ),

              // <<< THAY ĐỔI: Thay thế trailing icon bằng IconButton >>>
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[700],
                tooltip: 'Xóa',
                onPressed: () {
                  // Gọi hàm xóa
                  _deleteItem(saveItem);
                },
              ),

              onTap: () {
                // Bạn vẫn có thể giữ logic điều hướng ở đây
                // Ví dụ: Điều hướng đến trang chi tiết nhà hàng
                // Navigator.push(context, ...);
              },
            ),
          );
        },
      ),
    );
  }

  // Hàm build (giữ nguyên)
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
      body: _buildBody(),
    );
  }
}