import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';

abstract class RestaurantSaveRepository {
  Future<List<Save>> getSavesByUid(String uid);
  Future<void> addSave(Save save);
  Future<void> deleteSave(String id);
}