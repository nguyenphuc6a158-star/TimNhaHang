import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/app_routes.dart';

class CustomerBottomNav extends StatefulWidget {
  final int initialIndex;
  const CustomerBottomNav({super.key, required this.initialIndex});
  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
 late int currentIndex;

  final List<IconData> _icons = [
    Icons.home,
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
              color: Colors.redAccent, 
              boxShadow: const [BoxShadow(
                    color: Colors.black45, 
                    blurRadius: 4)], 
          ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate( _icons.length, (index) {
            return GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = index;
                  });
                  _onItemTapped(context, index);
                },
                child: Icon(
                  _icons[index],
                  color: currentIndex == index ?Colors.blue : Colors.amber,
                  size: 28,
                  ),
                );
          }),
        ),
      );
  }


  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.notes);
        break;
    }
  }
}