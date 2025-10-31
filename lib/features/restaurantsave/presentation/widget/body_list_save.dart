// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_restaurant.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';

class BodyListSave extends StatelessWidget {
  final Future<void> Function() loadSavedData;
  final Function(Save) deleteItem;
  final List<Save> savedList;
  final GetRestaurant getRestaurant;
  final Function(Restaurant) openDetailRestaurant;
  const BodyListSave({
    super.key,
    required this.loadSavedData, 
    required this.savedList,
    required this.deleteItem,
    required this.getRestaurant,
    required this.openDetailRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadSavedData,
      child: ListView.builder(
        itemCount: savedList.length,
        itemBuilder: (context, index) {
          final saveItem = savedList[index];
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
                  deleteItem(saveItem);
                },
              ),

              onTap: () async {
                final restaurant = await getRestaurant(saveItem.restaurantId);
                if (restaurant != null) {
                  openDetailRestaurant(restaurant);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nhà hàng không tồn tại hoặc đã bị xóa")),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
  
}