import 'package:cloud_firestore/cloud_firestore.dart';

class AttendeeService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  Future<void> registerAttendee({
    required String name,
    required String address,
    required String contact,
    required String branchId,
    required String serviceId,
    required String registeredBy,
  }) async {

    await _firestore.collection('registrations').add({

      'name': name,
      'address': address,
      'contact': contact,

      'time': Timestamp.now(),

      'registeredBy': registeredBy,

      'branchId': branchId,

      'serviceId': serviceId,

    });

  }

}