import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/history/domain/respositories/bill_respository.dart';

class AddBill{
  final BillReposiitory repository;
  AddBill(this.repository);
  Future<void> call(Bill bill) => repository.createBill(bill);
}