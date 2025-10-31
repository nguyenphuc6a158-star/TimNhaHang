import 'package:timnhahang/features/history/data/data/bill_remote_datasouce.dart';
import 'package:timnhahang/features/history/data/models/bill_model.dart';
import 'package:timnhahang/features/history/domain/entities/bill.dart';
import 'package:timnhahang/features/history/domain/respositories/bill_respository.dart';

class BillRepositoryImpl extends BillReposiitory {
  final BillsRemoteDatasource remoteDataSource;
  BillRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createBill(Bill bill) async {
    BillModel billModel = BillModel.fromEntity(bill);
    await remoteDataSource.add(billModel);
  }
  @override
  Future<void> deleteBill(String id) async {
    await remoteDataSource.delete(id);
  }

  @override
  Future<Bill> getBill(String id) async {
    BillModel? billModel = await remoteDataSource.getBill(id);
    if (billModel == null) {
      throw Exception('Bill not found');
    }
    return billModel;
  }

  @override
  Future<List<Bill>> getAllBillsByUid(String uid) async {
    List<BillModel> billModels = await remoteDataSource.getAllBillsByUid(uid);
    return billModels;
  }

  @override
  Future<List<Bill>> getBills() async {
    List<BillModel> billModels = await remoteDataSource.getAll();
    return billModels;
  }
  @override
  Future<void> updateBill(Bill bill) async {
    await remoteDataSource.update(BillModel.fromEntity(bill));
  }
  
}