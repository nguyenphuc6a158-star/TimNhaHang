import 'package:flutter/material.dart';
import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';

class ListDataHistory extends StatelessWidget {
  final List<Restaurant> listRestaurantFromBill;
  final List<Bill> listBill;
  final Function(Restaurant) openDetailRestaurant;
  const ListDataHistory({
    super.key,
    required this.listBill,
    required this.listRestaurantFromBill,
    required this.openDetailRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return listRestaurantFromBill.isEmpty ? const Center(child: Text("Chưa có lịch sử đặt bàn")) : ListView.builder(
      itemCount: listRestaurantFromBill.length,
      itemBuilder: (context, index) {
        final restaurant = listRestaurantFromBill[index];
        final bill = listBill[index];
        return ListTile(
          title: Text(restaurant.name),
          subtitle: Text("${restaurant.address}\nĐặt bàn lúc: ${bill.bookingTime}",),
          leading: Image.network(
            restaurant.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          onTap: () {
            openDetailRestaurant(restaurant);
          },
        );
      },
    ); 
  }
}