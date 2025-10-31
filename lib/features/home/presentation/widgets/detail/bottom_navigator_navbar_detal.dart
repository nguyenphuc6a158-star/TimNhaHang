// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BottomNavigatorNavbarDetal extends StatelessWidget {
  final VoidCallback openOrderForm;
  
  const BottomNavigatorNavbarDetal({
    super.key,
    required this.openOrderForm,
  });

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
          openOrderForm;
        },
        label: const Text('Đặt bàn'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF42A5F5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}