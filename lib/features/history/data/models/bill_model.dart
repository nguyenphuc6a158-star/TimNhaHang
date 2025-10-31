import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timnhahang/features/history/domain/entities/bill.dart';

class BillModel extends Bill{
  const BillModel({
    required super.id,
    required super.uid,
    required super.resid,
    required super.createdAt,
    required super.bookingTime,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      resid: data['resid'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookingTime: (data['bookingTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
 
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'resid': resid,
    'createdAt': Timestamp.fromDate(createdAt),
    'bookingTime': Timestamp.fromDate(bookingTime),
  };

  factory BillModel.fromEntity(Bill e) => BillModel(
    id: e.id,
    uid: e.uid,
    resid: e.resid,
    createdAt: e.createdAt,
    bookingTime: e.bookingTime,
  );  
} 