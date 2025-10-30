import 'package:timnhahang/features/restaurantsave/data/data/restaurant_save_remote_datasource.dart';
import 'package:timnhahang/features/restaurantsave/data/model/save_model.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';
import 'package:timnhahang/features/restaurantsave/domain/repositories/restaurant_save_repository.dart';

class RestaurantSaveRepositoryImpl extends RestaurantSaveRepository {
  final RestaurantSaveRemoteDatasource remoteDatasource;

  RestaurantSaveRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> addSave(Save save) async {
    SaveModel saveModel = SaveModel.fromEntity(save);
    await remoteDatasource.add(saveModel);
  }

  @override
  Future<List<Save>> getSavesByUid(String uid) async {
    List<SaveModel> saves = await remoteDatasource.getAllByUid(uid);
    return saves;
  }

  @override
  Future<void> deleteSave(String id) async {
    await remoteDatasource.delete(id);
  }
}