import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<Restaurant?> getRestaurant(String id);
  Future<void> updateRestaurant(Restaurant restaurant);
  Future<List<Restaurant>> searchRestaurant(String text);
}
