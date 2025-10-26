
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/models/restaurant_model.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/repositories/restaurant_repository.dart';

class RestaurantRepositoryImpl extends RestaurantRepository {
  final RestaurantRemoteDatasource remoteDataSource;
  RestaurantRepositoryImpl(this.remoteDataSource);
  @override
  Future<List<Restaurant>> getRestaurants() async {
    List<RestaurantModel> restaurantModels = await remoteDataSource.getAll();
    return restaurantModels;
  }
  @override
  Future<void> updateNote(Restaurant restaurant) async {
    await remoteDataSource.update(RestaurantModel.fromEntity(restaurant));
  }
}