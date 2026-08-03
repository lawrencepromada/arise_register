import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAttendancePdf({
    required String branchName,
    required String serviceName,
    required DateTime serviceDate,
    required List<QueryDocumentSnapshot> registrations,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        margin: const pw.EdgeInsets.all(24),

        build: (context) => [

          pw.Center(
            child: pw.Column(
              children: [

                pw.Text(
                  "ARISE AND SHINE GLORY MINISTRIES INTERNATIONAL",
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Text(
                  "ARISE REGISTER",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text(
                  "ATTENDANCE REGISTER",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Divider(),

          pw.SizedBox(height: 10),

          pw.Row(
            children: [

              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    infoRow(
                      "Branch",
                      branchName,
                    ),

                    infoRow(
                      "Service",
                      serviceName,
                    ),

                    infoRow(
                      "Date",
                      DateFormat(
                        "dd MMMM yyyy",
                      ).format(serviceDate),
                    ),

                    infoRow(
                      "Generated On",
                      DateFormat(
                        "dd MMM yyyy   hh:mm a",
                      ).format(now),
                    ),

                    infoRow(
                      "Total Attendance",
                      registrations.length.toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 18),

          buildTable(registrations),
        ],
      ),
    );

    final Uint8List bytes = await pdf.save();

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
    );
  }

  static pw.Widget infoRow(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(
        vertical: 3,
      ),
      child: pw.Row(
        children: [

          pw.SizedBox(
            width: 110,
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Text(":  $value"),
        ],
      ),
    );
  }

  static pw.Widget buildTable(
      List<QueryDocumentSnapshot> registrations) {

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(),

      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
      ),

      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),

      cellAlignment: pw.Alignment.centerLeft,

      headers: const [

        "No",

        "Name",

        "Address",

        "Contact",

        "Time",

        "Registered By",
      ],

      data: List.generate(
        registrations.length,
        (index) {

          final item = registrations[index].data()
              as Map<String, dynamic>;

          String time = "";

          if (item["time"] is Timestamp) {
            time = DateFormat(
              "hh:mm a",
            ).format(
              (item["time"] as Timestamp).toDate(),
            );
          }

          return [

            "${index + 1}",

            item["name"] ?? "",

            item["address"] ?? "",

            item["contact"] ?? "",

            time,

            item["registeredBy"] ?? "",
          ];
        },
      ),
    );
  }
}