// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

/// A generic Firestore DataSource for basic CRUD operations.
/// T = Model type that represents the Firestore document.
class FirebaseRemoteDS<T> {
  final String collectionName;
  final T Function(DocumentSnapshot doc) fromFirestore;
  final Map<String, dynamic> Function(T item) toFirestore;

  FirebaseRemoteDS({
    required this.collectionName,
    required this.fromFirestore,
    required this.toFirestore,
  });

  CollectionReference get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  /// Get all documents in the collection
  Future<List<T>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) {
      final data = fromFirestore(doc);
      return data;
    }).toList();
  }

  /// Get a single document by ID
  Future<T?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return fromFirestore(doc);
  }

  /// Add a new document
  Future<String> add(T item) async {
    final docRef = await _collection.add(toFirestore(item));
    return docRef.id;
  }

  Future<void> set(String id, T item) async {
    await _collection.doc(id).set(toFirestore(item));
  }

  /// Update an existing document
  Future<void> update(String id, T item) async {
    await _collection.doc(id).update(toFirestore(item));
  }

  /// Delete a document
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  /// Listen to realtime changes in a collection
  Stream<List<T>> watchAll() {
    return _collection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((e) => fromFirestore(e)).toList());
  }

  Future<List<T>> searchByField({
    required String field,
    required String prefix,
    int? limit,
  }) async {
    if (prefix.isEmpty) {
      return [];
    }
    try {
      Query query = _collection;

      query = query
          .where(field, isGreaterThanOrEqualTo: prefix)
          .where(field, isLessThan: '$prefix\uf8ff')
          .orderBy(field);
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((e) => fromFirestore(e)).toList();
    } catch (e) {
      print("Lỗi khi tìm kiếm theo prefix trong Firestore: $e");
      return [];
    }
  }

  Future<List<T>> getAllById(String field, String id) async {
    final snapshot = await _collection.where(field, isEqualTo: id).get();
    final list = snapshot.docs.map((doc) => fromFirestore(doc)).toList();

    // 3. Trả về đúng kiểu List<T>
    return list;
  }
}
