// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_new

import 'package:flutter/material.dart';
import 'package:timnhahang/features/history/data/data/bill_remote_datasouce.dart';
import 'package:timnhahang/features/history/data/respositories/bill_repository_impl.dart';
import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/history/domain/usecase/add_bill.dart';

class OrderForm extends StatefulWidget {
  final String resid;
  final String uid;
  late final _remote = BillsRemoteDataSourceImpl();
  late final _repo = BillRepositoryImpl(_remote);
  late final _addBill = AddBill(_repo);

  OrderForm({
    super.key,
    required this.resid,
    required this.uid,
  });

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _bookingTimeController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _bookingTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickBookingTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _bookingTimeController.text = _selectedDateTime!.toString();
    });
  }

  /// Hàm lưu (Tạm thời chỉ in ra console và đóng lại)
  void _saveBooking() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final addBill = widget._addBill;
    final newBill = new Bill(
      id: '', 
      uid: widget.uid, 
      resid: widget.resid, 
      createdAt: DateTime.now(), 
      bookingTime: _selectedDateTime!,
    );
    addBill(newBill);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt bàn thành công')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn giờ đặt bàn'),
        centerTitle: true,
      ),
      body: Center(
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

