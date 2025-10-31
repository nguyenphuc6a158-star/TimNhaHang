import 'package:timnhahang/core/data/firebase_remote_datasource.dart';
import 'package:timnhahang/features/history/data/models/bill_model.dart';

abstract class BillsRemoteDatasource {
  Future<List<BillModel>> getAll();
  Future<BillModel?> getBill(String id);
  Future<void> add(BillModel bill);
  Future<void> update(BillModel bill);
  Future<void> delete(String id);
  Future<List<BillModel>> getAllBillsByUid(String id);
}

class BillsRemoteDataSourceImpl implements BillsRemoteDatasource {
  final FirebaseRemoteDS<BillModel> _remoteSource;
  BillsRemoteDataSourceImpl() : _remoteSource = FirebaseRemoteDS<BillModel>(
    collectionName: 'bills',
    fromFirestore: (doc) => BillModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<List<BillModel>> getAll() async {
    List<BillModel> bills = [];
    bills = await _remoteSource.getAll();
    return bills;
  }

  @override
  Future<BillModel?> getBill(String id) async {
    BillModel? bill = await _remoteSource.getById(id);
    return bill;
  }

  @override
  Future<void> add(BillModel bill) async {
    await _remoteSource.add(bill);
  }

  @override
  Future<void> update(BillModel bill) async {
    await _remoteSource.update(bill.id.toString(), bill);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
  
  @override
  Future<List<BillModel>> getAllBillsByUid(String uid) async{
    List<BillModel> bills = await _remoteSource.getAllById('uid', uid);
    return bills;
  }
}