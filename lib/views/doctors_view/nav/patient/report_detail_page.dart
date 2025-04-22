import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meet_a_doc/provider/pdfMaker.dart';
import 'package:meet_a_doc/services/api_service.dart';
import 'package:meet_a_doc/services/firestore_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // For formatted filenames

class ReportDetailPage extends StatefulWidget {
  final String report;
  final String patientid;

  const ReportDetailPage(
      {super.key, required this.report, required this.patientid});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  var currentUser = {};
  var patient;
  var patientName;
  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    currentUser = await FirestoreService.getUserData(
        FirebaseAuth.instance.currentUser!.uid);
    patient = await FirestoreService.getUserData(widget.patientid);
    patientName = patient['fullName'];
    print("------------------------------------------------------" +
        patientName +
        " " +
        currentUser['fullName']);
  }

  // Function to save the report as a text file
  Future<void> _shareReport() async {
    final pdfFile = await PdfMaker.generatePdf(
        widget.report
            .replaceAll('*', '->'), // Replace '*' with '->' in the report
        currentUser['fullName'],
        patientName);
    OpenFile.open(pdfFile.path);

    // try {
    //   // Get the temporary directory to save the file
    //   final directory = await getTemporaryDirectory();

    //   // Generate a filename with a timestamp
    //   final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    //   final file = File('${directory.path}/patient_report_$timestamp.txt');

    //   // Save the report content as text
    //   await file.writeAsString(widget.report);

    //   // Share the file
    //   await Share.shareXFiles([XFile(file.path)], text: 'Patient Report');

    //   // Show success message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Report shared successfully!')),
    //   );
    // } catch (e) {
    //   debugPrint('Error sharing report: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Failed to share the report')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF108DA3);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            const Text("Patient Report", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report.replaceAll('*', '->'),
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating action button to share the report
      floatingActionButton: FloatingActionButton(
        onPressed: _shareReport,
        backgroundColor: primaryColor, // Custom background color
        child: const Icon(
          Icons.share,
          color: Colors.white, // White color icon
        ),
      ),
    );
  }
}
