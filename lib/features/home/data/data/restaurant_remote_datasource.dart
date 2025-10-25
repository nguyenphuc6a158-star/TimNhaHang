import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/home/data/models/restaurant_model.dart';

abstract class RestaurantRemoteDatasource {
  Future<List<RestaurantModel>> getAll();
}
class RestaurantsRemoteDataSourceImpl implements RestaurantRemoteDatasource {
  final FirebaseRemoteDS<RestaurantModel> _remoteSource;
  RestaurantsRemoteDataSourceImpl() : _remoteSource = FirebaseRemoteDS<RestaurantModel>(
    collectionName: 'restaurant',
    fromFirestore: (doc) => RestaurantModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );
  @override
  Future<List<RestaurantModel>> getAll() async {
    List<RestaurantModel> restaurants = [];
    restaurants = await _remoteSource.getAll();
    return restaurants;
  }
}