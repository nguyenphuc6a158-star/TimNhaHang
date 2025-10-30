import 'package:timnhahang/features/history/domain/entities/bill.dart';

abstract class BillReposiitory {
  Future<List<Bill>> getBills();
  Future<Bill> getBill(String id);
  Future<void> createBill(Bill note);
  Future<void> updateBill(Bill note);
  Future<void> deleteBill(String id);
}