import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String collection = "users";

  Future<void> createUser({
    required String uid,
    required String fullName,
    required String email,
    required String role,
    required String branchId,
    required String branchName,
    required String createdBy,
  }) async {
    await _firestore.collection(collection).doc(uid).set({
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "role": role,
      "branchId": branchId,
      "branchName": branchName,
      "active": true,
      "createdBy": createdBy,
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(collection)
        .doc(uid)
        .update(data);
  }

  Future<void> disableUser(String uid) async {
    await _firestore.collection(collection).doc(uid).update({
      "active": false,
    });
  }

  Future<void> enableUser(String uid) async {
    await _firestore.collection(collection).doc(uid).update({
      "active": true,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection(collection).doc(uid).delete();
  }

  Stream<QuerySnapshot> getUsers() {
    return _firestore
        .collection(collection)
        .orderBy("fullName")
        .snapshots();
  }

  Stream<QuerySnapshot> getUsersByBranch(
      String branchId) {
    return _firestore
        .collection(collection)
        .where("branchId", isEqualTo: branchId)
        .orderBy("fullName")
        .snapshots();
  }

  Future<DocumentSnapshot> getUser(String uid) {
    return _firestore
        .collection(collection)
        .doc(uid)
        .get();
  }
}