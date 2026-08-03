import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterAttendeesScreen extends StatefulWidget {
  final String branchId;
  final String branchName;

  const RegisterAttendeesScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<RegisterAttendeesScreen> createState() => _RegisterAttendeesScreenState();
}

class _RegisterAttendeesScreenState extends State<RegisterAttendeesScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final FocusNode nameFocus = FocusNode();

  int todayRegistrations = 0;
String serviceName = "Loading Service...";
String? activeServiceId;
bool isLoadingService = true;

StreamSubscription? registrationSubscription;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _findActiveServiceAndListen();
  }

  @override
void dispose() {

  registrationSubscription?.cancel();

  nameController.dispose();
  phoneController.dispose();
  addressController.dispose();
  nameFocus.dispose();

  super.dispose();
}

  void _findActiveServiceAndListen() async {
    try {
      final snapshot = await _firestore
          .collection("services")
          .where("branchId", isEqualTo: widget.branchId)
          .where("active", isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final sId = doc.id;

        setState(() {
          activeServiceId = sId;
          serviceName = doc["serviceName"] ?? "Active Service";
          isLoadingService = false;
        });

        registrationSubscription = _firestore
    .collection("registrations")
    .where("serviceId", isEqualTo: sId)
    .snapshots()
    .listen((regSnapshot) {

  if (mounted) {
    setState(() {
      todayRegistrations = regSnapshot.docs.length;
    });
  }

});
      } else {
        setState(() {
          serviceName = "No Active Service Started";
          isLoadingService = false;
        });
      }
    } catch (e) {
      setState(() {
        serviceName = "Error loading service";
        isLoadingService = false;
      });
    }
  }

  Future<void> registerPerson() async {
    if (activeServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot register. No service is currently active."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final attendeeName = nameController.text.trim();
      final attendeePhone = phoneController.text.trim();
      final attendeeAddress = addressController.text.trim();
      final currentUser = FirebaseAuth.instance.currentUser;

String registeredByName = "Unknown";

if (currentUser != null) {
  final userSnapshot = await _firestore
      .collection("users")
      .doc(currentUser.uid)
      .get();

  if (userSnapshot.exists) {
    registeredByName = userSnapshot.data()?["name"] ?? "Unknown";
  }
}

      await _firestore.collection("registrations").add({
        "name": attendeeName,
        "contact": attendeePhone.isEmpty ? "N/A" : attendeePhone,
        "address": attendeeAddress.isEmpty ? "N/A" : attendeeAddress,
        "branchId": widget.branchId,
        "branchName": widget.branchName,
        "serviceId": activeServiceId,
        "serviceName": serviceName,
        "registeredById": currentUser!.uid,
        "registeredBy": registeredByName,
        "time": FieldValue.serverTimestamp(),
      });

      await _firestore.collection("services").doc(activeServiceId).update({
        "totalRegistrations": FieldValue.increment(1),
      });

      if (!mounted) return;
      Navigator.pop(context); 

      nameController.clear();
      phoneController.clear();
      addressController.clear();

      FocusScope.of(context).requestFocus(nameFocus);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to register: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "ARISE REGISTER",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    widget.branchName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.amber,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    "Today's Registrations : $todayRegistrations",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 25),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Full Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          focusNode: nameFocus,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: "Enter full name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Full Name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "07XXXXXXXX",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Location / Address",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: addressController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: "Example: Katabi",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoadingService || activeServiceId == null
                        ? null 
                        : registerPerson,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      "REGISTER",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}