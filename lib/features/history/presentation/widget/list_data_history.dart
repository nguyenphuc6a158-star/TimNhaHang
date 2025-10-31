import 'package:flutter/material.dart';
import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/home/domain/entities/restaurant.dart';
import 'package:intl/intl.dart';


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
        final displayBookingTime = DateFormat('dd/MM/yyyy HH:mm').format(bill.bookingTime);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:Image.network(
                restaurant.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(restaurant.name),
            subtitle: Text("${restaurant.address}\nĐặt bàn lúc: $displayBookingTime",),
            onTap: () {
              openDetailRestaurant(restaurant);
            },
          )
        );
      },
    ); 
  }
}