class Bill {
  final String id;
  final String uid;
  final String resid;
  final DateTime createdAt;
  final DateTime bookingTime;
  
  const Bill({
    required this.id,
    required this.uid,
    required this.resid,
    required this.createdAt,
    required this.bookingTime
  });

  @override
  String toString() {
    return "Bill(id: $id, uid: $uid, resid: $resid, createdAt: $createdAt, bookingTime: $bookingTime)";
  }
}