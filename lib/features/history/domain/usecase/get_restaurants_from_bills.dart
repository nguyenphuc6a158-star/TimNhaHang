import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/repositories/restaurant_repository.dart';

class GetRestaurantsFromBills {
  final RestaurantRepository restaurantRepo;
  GetRestaurantsFromBills(this.restaurantRepo);
  Future<List<Restaurant>> call(List<Bill> bills) async {
    final futures = bills.map((bill) => restaurantRepo.getRestaurant(bill.resid));
    final result = await Future.wait(futures);
    return result.whereType<Restaurant>().toList();
  }
}