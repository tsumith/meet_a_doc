// import 'package:flutter/material.dart';
// import 'package:meet_a_doc/services/api_service.dart';
// import 'package:meet_a_doc/services/api_service.dart' as ApiService;
// import 'package:meet_a_doc/services/firebase_service.dart';

// class PatientsReportPage extends StatefulWidget {
//   const PatientsReportPage({Key? key}) : super(key: key);

//   @override
//   State<PatientsReportPage> createState() => _PatientsReportPageState();
// }

// class _PatientsReportPageState extends State<PatientsReportPage> {
//   List<dynamic>? _reports;
//   @override
//   void initState() {
//     super.initState();
//     _getData();
//   }

//   void _getData() async {
//     final user = await FirebaseService.getCurrentUser();
//     final docid = await getDoctorId(user!.uid);
//     final reports = await ApiService.getReportsforPatient(docid, user.uid);
//     setState(() {
//       _reports = reports;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: Icon(Icons.arrow_back)),
//           title: const Text('Patients Reports'),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(10),
//             child: Column(children: [
//               const SizedBox(height: 20),
//               const Text(
//                 'Your Reports',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               Container(
//                 height: 500,
//                 child: ListView.builder(
//                     itemCount: _reports!.length,
//                     itemBuilder: (cont, index) {
//                       return Card(
//                         child: Text("report of ${_reports?[index]['report']}"),
//                       );
//                     }),
//               )
//             ]),
//           ),
//         ));
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:meet_a_doc/services/api_service.dart';
import 'package:meet_a_doc/services/api_service.dart' as ApiService;
import 'package:meet_a_doc/services/firebase_service.dart';

class PatientsReportPage extends StatefulWidget {
  const PatientsReportPage({Key? key}) : super(key: key);

  @override
  State<PatientsReportPage> createState() => _PatientsReportPageState();
}

class _PatientsReportPageState extends State<PatientsReportPage> {
  List<dynamic>? _reports;
  bool _isLoading = true; // To show loading state

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() async {
    setState(() {
      _isLoading = true;
    });
    final user = await FirebaseService.getCurrentUser();
    if (user != null) {
      final docid = await getDoctorId(user.uid);
      final reports = await ApiService.getReportsforPatient(docid, user.uid);
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        // Handle the case where the user is not logged in
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff10A37F),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Your Medical Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports == null || _reports!.isEmpty
              ? const Center(child: Text('No reports available.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _reports!.length,
                  itemBuilder: (context, index) {
                    final report = _reports![index];
                    // Assuming your report data has fields like 'report', 'date', 'description'

                    final reportDate = report['createdAt'] != null
                        ? DateFormat('MMM dd, yyyy').format(
                            DateTime.parse(report['createdAt'].toString()))
                        : 'N/A';
                    final reportDescription =
                        report['description'] ?? 'No description provided.';

                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.document_scanner_outlined,
                            size: 32, color: Colors.blueGrey),
                        title: Text(
                          reportDate,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reportDescription,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600])),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReportDetailScreen(report: report),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class ReportDetailScreen extends StatelessWidget {
  final dynamic report;

  const ReportDetailScreen({Key? key, required this.report}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String reportContent =
        (report['report'] as String?)?.replaceAll('*', '->') ??
            'No report content available.';
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff10A37F),
        title: Text(
          'Report Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              reportContent,
              style: theme.textTheme.bodyLarge,
            ),
            if (report['createdAt'] != null)
              Text(
                ' \n Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(report['createdAt'].toString()))}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
            const SizedBox(height: 20),

            // Display the main content of the report here.
            // Adjust based on the actual structure of your 'report' data.

            // You can add more sections here to display other relevant information
          ],
        ),
      ),
    );
  }
}
