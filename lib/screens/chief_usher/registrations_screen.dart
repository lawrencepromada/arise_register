import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/pdf_service.dart';

class RegistrationsScreen extends StatefulWidget {
  final String branchId;
  final String branchName;

  const RegistrationsScreen({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  String? selectedServiceId;
  String selectedServiceName = "";
  DateTime? selectedServiceDate;
  
  List<QueryDocumentSnapshot> allBranchServices = [];
  List<QueryDocumentSnapshot> filteredRegistrations = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      final serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .get();

      final allServices = serviceSnapshot.docs;

      allBranchServices = allServices.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['branchId'] == widget.branchId;
      }).toList();

      if (allBranchServices.isNotEmpty) {
        allBranchServices.sort((a, b) {
          final aDate = ((a.data() as Map<String, dynamic>)['date'] as Timestamp?)?.toDate() ?? DateTime(0);
          final bDate = ((b.data() as Map<String, dynamic>)['date'] as Timestamp?)?.toDate() ?? DateTime(0);
          return bDate.compareTo(aDate);
        });

        final latestService = allBranchServices.first;
        selectedServiceId = latestService.id;
        final data = latestService.data() as Map<String, dynamic>;
        selectedServiceName = data['serviceName'] ?? 'Sunday Service';
        selectedServiceDate = (data['date'] as Timestamp?)?.toDate();

        await _fetchAndFilterRegistrations();
      }
    } catch (e) {
      debugPrint("Error loading services: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAndFilterRegistrations() async {
    if (selectedServiceId == null) return;
    
    final registrationSnapshot = await FirebaseFirestore.instance
        .collection('registrations')
        .get();

    final allRegs = registrationSnapshot.docs;

    final filtered = allRegs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['serviceId'] == selectedServiceId;
    }).toList();

    filtered.sort((a, b) {
      final aTime = ((a.data() as Map<String, dynamic>)['time'] as Timestamp?)?.toDate() ?? DateTime(0);
      final bTime = ((b.data() as Map<String, dynamic>)['time'] as Timestamp?)?.toDate() ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    setState(() {
      filteredRegistrations = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrations"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : allBranchServices.isEmpty
              ? const Center(child: Text("No services found for this branch."))
              : RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "ARISE REGISTER",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            const Text("Select Service: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButton<String>(
                                value: selectedServiceId,
                                isExpanded: true,
                                items: allBranchServices.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final name = data['serviceName'] ?? 'Sunday Service';
                                  final dateStamp = data['date'] as Timestamp?;
                                  final formattedDate = dateStamp != null 
                                      ? DateFormat('yyyy-MM-dd').format(dateStamp.toDate())
                                      : '';
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text("$name ($formattedDate)"),
                                  );
                                }).toList(),
                                onChanged: (value) async {
                                  if (value != null) {
                                    final selectedDoc = allBranchServices.firstWhere((d) => d.id == value);
                                    final data = selectedDoc.data() as Map<String, dynamic>;
                                    setState(() {
                                      selectedServiceId = value;
                                      selectedServiceName = data['serviceName'] ?? 'Sunday Service';
                                      selectedServiceDate = (data['date'] as Timestamp?)?.toDate();
                                      isLoading = true;
                                    });
                                    await _fetchAndFilterRegistrations();
                                    setState(() => isLoading = false);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        Text("Branch : ${widget.branchName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("Total Registrations : ${filteredRegistrations.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                          onPressed: filteredRegistrations.isEmpty
                              ? null
                              : () async {
                                  await PdfService.generateAttendancePdf(
                                    branchName: widget.branchName,
                                    serviceName: selectedServiceName,
                                    serviceDate: selectedServiceDate ?? DateTime.now(),
                                    registrations: filteredRegistrations,
                                  );
                                },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Generate PDF Report"),
                        ),
                        const SizedBox(height: 15),

                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: DataTable(
                                border: TableBorder.all(),
                                columns: const [
                                  DataColumn(label: Text("No", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Address", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Contact", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text("Registered By", style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: List.generate(
                                  filteredRegistrations.length,
                                  (index) {
                                    final item = filteredRegistrations[index].data() as Map<String, dynamic>;
                                    
                                    
                                    debugPrint("REGISTRATION DOCUMENT MAP: $item");

                                    return DataRow(
                                      cells: [
                                        DataCell(Text("${index + 1}")),
                                        DataCell(Text(item["name"] ?? "[Missing Name]")),
                                        DataCell(Text(item["address"] == "" || item["address"] == null ? "N/A" : item["address"])),
                                       DataCell(
  Text(
    item["contact"] == "" || item["contact"] == null
        ? "No Contact"
        : item["contact"],
  ),
),
                                        DataCell(
                                          Text(
                                            () {
                                              final dynamic rawTime = item["time"] ?? item["registeredAt"];
                                              if (rawTime == null) return "Missing Time";
                                              if (rawTime is Timestamp) return DateFormat('hh:mm a').format(rawTime.toDate());
                                              if (rawTime is String) return rawTime;
                                              return "Invalid Format";
                                            }(),
                                          ),
                                        ),
                                        DataCell(Text(item["registeredBy"] ?? "Unknown")),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}