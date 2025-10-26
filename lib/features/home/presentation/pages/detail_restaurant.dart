import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:timnhahang/features/home/domain/usecase/update_restaurant.dart';

class DetailRestaurantPage extends StatelessWidget {
  final Restaurant restaurant;
  final UpdateRestaurant updateRestaurant;
  const DetailRestaurantPage({
    super.key,
    required this.restaurant,
    required this.updateRestaurant
    });
  void backPrePage (BuildContext context) {
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            backPrePage(context);
          },
        ),
        title: Text(restaurant.name),
        centerTitle: true,
      ),
      body: Text(restaurant.name),
    );
  }
}