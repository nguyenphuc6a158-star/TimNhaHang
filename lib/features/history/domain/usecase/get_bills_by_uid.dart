import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/history/domain/respositories/bill_respository.dart';

class GetAllBillsByUid{
  final BillReposiitory repository;
  GetAllBillsByUid(this.repository);
  Future<List<Bill>> call(String uid) => repository.getAllBillsByUid(uid);
}