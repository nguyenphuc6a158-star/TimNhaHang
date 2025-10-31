// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:timnhahang/features/home/presentation/pages/form_order.dart';

class BottomNavigatorNavbarDetal extends StatelessWidget {
  final String restaurantID;
  final String uId;
  const BottomNavigatorNavbarDetal({
    super.key,
    required this.restaurantID,
    required this.uId,
  });

  void openOrderForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderForm(resid: restaurantID, uid: uId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          openOrderForm(context);
        },
        label: const Text('Đặt bàn'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
