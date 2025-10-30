import 'package:timnhahang/features/history/domain/respositories/bill_respository.dart';

class DeleteNote {
  final BillReposiitory repository;
  DeleteNote(this.repository);
  Future<void> call(String id) async {
    await repository.deleteBill(id);
  }
}