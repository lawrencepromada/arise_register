import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceSetupScreen extends StatefulWidget {
  final String branchId;
  final String branchName;

  const ServiceSetupScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<ServiceSetupScreen> createState() => _ServiceSetupScreenState();
}

class _ServiceSetupScreenState extends State<ServiceSetupScreen> {
  String? selectedService;
  bool serviceStarted = false;
  
  String? activeServiceId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController otherController = TextEditingController();

  bool get isHQ => widget.branchId == "HQ";

  @override
  void initState() {
    super.initState();
    loadActiveService();
  }

  @override
  void dispose() {
    otherController.dispose();
    super.dispose();
  }

  Future<void> loadActiveService() async {
    final snapshot = await _firestore
        .collection("services")
        .where("branchId", isEqualTo: widget.branchId)
        .where("active", isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;

      setState(() {
        activeServiceId = doc.id;
        serviceStarted = true;
        selectedService = doc["serviceName"];
      });
    }
  }

  Widget buildRadio(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedService,
      onChanged: serviceStarted
          ? null
          : (v) {
              setState(() {
                selectedService = v;
              });
            },
    );
  }

  Future<void> startService() async {
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a service."),
        ),
      );
      return;
    }

    if (selectedService == "Other Service" &&
        otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter service name."),
        ),
      );
      return;
    }

    final serviceName = selectedService == "Other Service"
        ? otherController.text.trim()
        : selectedService!;

    String serviceType = "Regular";

    if (serviceName.contains("Convention")) {
      serviceType = "Convention";
    }

    if (selectedService == "Other Service") {
      serviceType = "Special";
    }

    try {
      final doc = await _firestore.collection("services").add({
        "serviceName": serviceName,
        "serviceType": serviceType,
        "branchId": widget.branchId,
        "branchName": widget.branchName,
        "active": true,
        "date": FieldValue.serverTimestamp(),
        "startedAt": FieldValue.serverTimestamp(),
        "endedAt": null,
        "totalRegistrations": 0,
      });

      if (!mounted) return;

      setState(() {
        serviceStarted = true;
        activeServiceId = doc.id; 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$serviceName started successfully."),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to start service: $e"),
        ),
      );
    }
  }

  Future<void> endService() async {
    if (activeServiceId == null) return;

    await _firestore
        .collection("services")
        .doc(activeServiceId)
        .update({
          "active": false,
          "endedAt": FieldValue.serverTimestamp(),
        });

    setState(() {
      serviceStarted = false;
      selectedService = null;
      activeServiceId = null;
      otherController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Service ended."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Setup"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ARISE REGISTER",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Branch: ${widget.branchName}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 35),
            const Text(
              "REGULAR SERVICES",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            buildRadio("Sunday Service"),
            buildRadio("Midweek Service"),
            buildRadio("Prayer Altar"),
            if (isHQ) ...[
              const SizedBox(height: 20),
              const Text(
                "CONVENTION",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildRadio("Convention Day 1"),
              buildRadio("Convention Day 2"),
              buildRadio("Convention Day 3"),
              buildRadio("Convention Day 4"),
            ],
            const SizedBox(height: 20),
            const Text(
              "SPECIAL SERVICE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            buildRadio("Other Service"),
            if (selectedService == "Other Service") ...[
              const SizedBox(height: 10),
              TextField(
                controller: otherController,
                enabled: !serviceStarted,
                decoration: const InputDecoration(
                  labelText: "Service Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 30),
            if (serviceStarted)
              Card(
                color: Colors.green.shade100,
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: Text(
                    selectedService == "Other Service"
                        ? otherController.text
                        : selectedService ?? "",
                  ),
                  subtitle: const Text("ACTIVE SERVICE"),
                ),
              ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(
                  serviceStarted ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  serviceStarted ? "END SERVICE" : "START SERVICE",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: serviceStarted ? Colors.red : null,
                ),
                onPressed: serviceStarted ? () => endService() : startService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}