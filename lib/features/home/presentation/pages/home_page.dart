import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_all_restaurant.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  late final _remote = RestaurantsRemoteDataSourceImpl();
  late final _repo = RestaurantRepositoryImpl(_remote);

  late final _getAllRestaurants = GetAllRestaurants(_repo);
  List<Restaurant> listRestaurants = [];
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }
  Future<void> _loadNotes() async {
    final restaurants = await _getAllRestaurants();
    setState(() {
      listRestaurants = restaurants;
    });
    print(listRestaurants);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Restaurants")),
      body: listRestaurants.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: listRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = listRestaurants[index];
          return ListTile(
            title: Text(restaurant.name),
            subtitle: Text(restaurant.address),
          );
        },
      ),
    );
  }
}