import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

class SrearchResultList extends StatelessWidget {
  final List<Restaurant> currentList;
  final Future<void> Function() loadRestaurants;
  final void Function(Restaurant restaurant) openDetailRestaurant;
  const SrearchResultList({
    super.key,
    required this.currentList,
    required this.loadRestaurants,
    required this.openDetailRestaurant,
  });

  @override
  Widget build(BuildContext context) {
     return RefreshIndicator(
      onRefresh: loadRestaurants, // Vẫn cho phép kéo để làm mới
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0), // Padding cho cả danh sách
        itemCount: currentList.length,
        itemBuilder: (context, index) {
          final restaurant = currentList[index];
          // Card cho ListView (Dùng Row: Ảnh bên trái, Text bên phải)
          return Card(
            margin: const EdgeInsets.only(
              bottom: 8.0,
            ), // Khoảng cách giữa các item
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                openDetailRestaurant(restaurant);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding bao quanh Row
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trên
                  children: [
                    // 1. Hình ảnh (Bên trái)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        width: 100, // Chiều rộng cố định
                        height: 100, // Chiều cao cố định
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Khoảng cách giữa ảnh và chữ
                    // 2. Thông tin (Bên phải)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Tên tối đa 2 dòng
                          ),
                          const SizedBox(height: 8),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 3, // Địa chỉ tối đa 3 dòng
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}