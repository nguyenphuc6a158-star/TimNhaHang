import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/history/domain/respositories/bill_respository.dart';

class UpdateBill{
  final BillReposiitory repository;
  UpdateBill(this.repository);
  Future<void> call(Bill bill) async {
    repository.updateBill(bill);
  }
}