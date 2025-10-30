import 'package:timnhahang/features/restaurantsave/domain/repositories/restaurant_save_repository.dart';

class DeleteSavedRestaurant {
  final RestaurantSaveRepository restaurantRepository;

  DeleteSavedRestaurant(this.restaurantRepository);

  Future<void> call(String id) async {
    await restaurantRepository.deleteSave(id);
  }
}
