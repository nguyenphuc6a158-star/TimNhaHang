import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/repositories/restaurant_repository.dart';

class GetAllRestaurants{
  final RestaurantRepository repository;
  GetAllRestaurants(this.repository);
  Future<List<Restaurant>> call() => repository.getRestaurats();
}