import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timnhahang/core/routing/app_routes.dart';

class CustomerBottomNav extends StatefulWidget {
  final int initialIndex;
  final String uid; // <-- (MỚI) Thêm thuộc tính để nhận uid

  const CustomerBottomNav({
    super.key,
    required this.initialIndex,
    required this.uid, // <-- (MỚI) Yêu cầu uid trong constructor
  });

  @override
  State<CustomerBottomNav> createState() => _CustomerBottomNavState();
}

class _CustomerBottomNavState extends State<CustomerBottomNav> {
  late int currentIndex;

  final List<IconData> _icons = [
    Icons.home,
    Icons.save,
    Icons.history,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                currentIndex = index;
              });
              _onItemTapped(context, index);
            },
            child: Icon(
              _icons[index],
              color: currentIndex == index ? Colors.amber : Colors.white,
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
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go('${AppRoutes.saved}/${widget.uid}');
        break;
      case 2:
        context.go('${AppRoutes.history}/${widget.uid}');
        break;
      case 3:
        // (CẬP NHẬT) Truyền uid vào route
        // Giả sử route profile của bạn là '/profile/:uid'
        context.go('${AppRoutes.setting}/${widget.uid}');
        break;
    }
  }
}
