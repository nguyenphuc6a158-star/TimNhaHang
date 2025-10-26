import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/data/data/restaurant_remote_datasource.dart';
import 'package:timnhahang/features/home/data/repositories/restaurant_repository_impl.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/get_all_restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';
import 'package:timnhahang/features/home/presentation/pages/detail_restaurant.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  late final _remote = RestaurantsRemoteDataSourceImpl();
  late final _repo = RestaurantRepositoryImpl(_remote);

  late final _getAllRestaurants = GetAllRestaurants(_repo);
  late final _updateRestaurant = UpdateRestaurant(_repo);
  bool isLoading = true;
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
      isLoading = false;
    });
  }
  void  openDetailRestaurant(Restaurant restaurant) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => DetailRestaurantPage(restaurant: restaurant, updateRestaurant: _updateRestaurant),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trang chủ"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: listRestaurants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: listRestaurants.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,        //Số cột trong lưới (2 cột)
            mainAxisSpacing: 8.0,     //Khoảng cách dọc giữa các item
            crossAxisSpacing: 8.0,    //Khoảng cách ngang giữa các item
          ),
          itemBuilder: (context, index) {
            final restaurant = listRestaurants[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  openDetailRestaurant(restaurant);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.grey, size: 40),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          },
        ),
      ),
    );
  }
}