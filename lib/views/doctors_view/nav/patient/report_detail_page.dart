import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // For formatted filenames

class ReportDetailPage extends StatefulWidget {
  final String report;

  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  // Function to save the report as a text file
  Future<void> _shareReport() async {
    try {
      // Get the temporary directory to save the file
      final directory = await getTemporaryDirectory();

      // Generate a filename with a timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/patient_report_$timestamp.txt');

      // Save the report content as text
      await file.writeAsString(widget.report);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Patient Report');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report shared successfully!')),
      );
    } catch (e) {
      debugPrint('Error sharing report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share the report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF108DA3);

    return Scaffold(
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
            child: Text(
              widget.report.replaceAll('*', '->'),
              style: const TextStyle(fontSize: 16, height: 1.4),
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
