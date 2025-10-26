import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<void> updateNote(Restaurant restaurant);
}