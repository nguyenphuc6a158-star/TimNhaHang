import 'package:flutter/material.dart';
import 'package:timnhahang/features/restaurantsave/domain/entities/save.dart';

class DialogConfirm extends StatelessWidget {
  final Save saveItem;
  const DialogConfirm({
    super.key,
    required this.saveItem
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận xóa'),
      content: Text(
        'Bạn có chắc muốn bỏ lưu nhà hàng "${saveItem.restaurantName}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}