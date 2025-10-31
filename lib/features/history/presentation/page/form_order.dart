// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
// KHÔNG CẦN IMPORT INTl NỮA

class OrderForm extends StatefulWidget {
  const OrderForm({super.key});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();

  // Dùng để hiển thị ngày giờ đã chọn lên ô input
  final _bookingTimeController = TextEditingController();

  // Biến để lưu giá trị DateTime thực tế
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _bookingTimeController.dispose();
    super.dispose();
  }

  /// Hàm chính: Mở cửa sổ chọn Ngày và Giờ
  Future<void> _pickBookingTime() async {
    // 1. CHỌN NGÀY
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) return;

    // 2. CHỌN GIỜ
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    // 3. KẾT HỢP NGÀY VÀ GIỜ
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // --- (ĐÂY LÀ DÒNG THAY ĐỔI) ---
      // Hiển thị giờ theo định dạng mặc định (toString())
      // Ví dụ: 2025-10-31 14:30:00.000
      _bookingTimeController.text = _selectedDateTime!.toString();
      // --- KẾT THÚC THAY ĐỔI ---
    });
  }

  /// Hàm lưu (Tạm thời chỉ in ra console và đóng lại)
  void _saveBooking() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bookingTime = _selectedDateTime;
    print('Lưu đặt bàn lúc: $bookingTime');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu đặt bàn (Tạm thời)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _bookingTimeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Giờ đặt bàn *',
                  hintText: 'Nhấn để chọn ngày và giờ',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onTap: _pickBookingTime,
                validator: (value) {
                  if (_selectedDateTime == null) {
                    return 'Vui lòng chọn giờ đặt bàn';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _saveBooking,
                icon: const Icon(Icons.save),
                label: const Text('Lưu đặt bàn'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

