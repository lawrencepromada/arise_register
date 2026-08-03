import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> hasActiveService(String branchId) async {
    final snapshot = await _firestore
        .collection('services')
        .where('branchId', isEqualTo: branchId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<String?> startService({
    required String branchId,
    required String branchName,
    required String serviceName,
    required String createdBy,
  }) async {
    if (await hasActiveService(branchId)) {
      return null;
    }

    final doc = await _firestore.collection('services').add({
      'branchId': branchId,
      'branchName': branchName,
      'serviceName': serviceName,
      'createdBy': createdBy,
      'date': Timestamp.now(),
      'startedAt': Timestamp.now(),
      'endedAt': null,
      'status': 'active',
      'totalRegistrations': 0,
    });

    return doc.id;
  }

  Future<void> endService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).update({
      'status': 'completed',
      'endedAt': Timestamp.now(),
    });
  }

  Future<DocumentSnapshot?> getActiveService(String branchId) async {
    final snapshot = await _firestore
        .collection('services')
        .where('branchId', isEqualTo: branchId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first;
  }
}