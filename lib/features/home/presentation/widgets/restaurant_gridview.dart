import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

class RestaurantGridview extends StatelessWidget{
  final Future<void> Function() loadRestaurants;
  final List<Restaurant> currentList;
  final void Function(Restaurant restaurant) openDetailRestaurant;

  const RestaurantGridview({
    super.key,
    required this.currentList,
    required this.loadRestaurants,
    required this.openDetailRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadRestaurants,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: currentList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.75, // Tỷ lệ cho GridView
          ),
          itemBuilder: (context, index) {
            final restaurant = currentList[index];
            // Card cho GridView (Dùng Expanded cho ảnh)
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  openDetailRestaurant(restaurant);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // Dùng Expanded
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}