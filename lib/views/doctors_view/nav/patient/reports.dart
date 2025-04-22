import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_a_doc/services/api_service.dart';
import 'package:meet_a_doc/services/firebase_service.dart';
import 'package:meet_a_doc/services/firestore_service.dart';
import 'package:meet_a_doc/views/doctors_view/nav/patient/report_detail_page.dart';

class ReportsPage extends StatefulWidget {
  final dynamic patientId;

  const ReportsPage({super.key, required this.patientId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _filteredReports = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _patientDetails;
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _getReports();
    _searchController.addListener(_onSearchChanged);
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _reports.where((report) {
        final dateTimeString = report['createdAt'];
        final DateTime reportDate = DateTime.parse(dateTimeString).toLocal();
        final formattedDate = DateFormat('dd MMM<\ctrl98> • hh:mm a')
            .format(reportDate)
            .toLowerCase();
        return formattedDate.contains(query);
      }).toList();
    });
  }

  Future<void> _getReports() async {
    List<Map<String, dynamic>> reports = await getReportsforPatient(
        FirebaseAuth.instance.currentUser!.uid, widget.patientId);
    setState(() {
      _reports = reports;
      _filteredReports = reports;
    });
  }

  Future<String> getPatientName(String patientId) async {
    final patient = await FirestoreService.getUserData(patientId);
    return patient['fullName'];
  }

  Future<void> _fetchPatientDetails(String id) async {
    final details = await getPatientDetails(id);
    setState(() {
      _patientDetails = details?['patientDetails']?[0];
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _fetchPatientDetails(widget.patientId);
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          Text(
            value ?? 'N/A',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    if (_patientDetails == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Loading patient details...')),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Details',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Diseases', _patientDetails?['diseases']),
          _buildDetailRow('Medications', _patientDetails?['medications']),
          _buildDetailRow('Allergies', _patientDetails?['allergies']),
          _buildDetailRow('Family History', _patientDetails?['familyHistory']),
          _buildDetailRow('Height', _patientDetails?['height']?.toString()),
          _buildDetailRow('Weight', _patientDetails?['weight']?.toString()),
          _buildDetailRow('Blood Type', _patientDetails?['bloodType']),
          _buildDetailRow(
              'Surgical History', _patientDetails?['surgicalHistory']),
          _buildDetailRow(
              'Other Conditions', _patientDetails?['otherConditions']),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF108DA3);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _getReports,
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 60, 20,
                      16 + (child == null ? 12 : 0)), // Adjust bottom padding
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: _isExpanded
                        ? BorderRadius.zero
                        : const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _toggleExpansion,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Reports of",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isExpanded
                                      ? 'Patient Details'
                                      : 'tap to view patient details',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                FutureBuilder<String>(
                                  future: getPatientName(widget.patientId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(color: Colors.white70),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                        'Error',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 5),
                                const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      color: Color.fromARGB(255, 20, 169, 196),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1.0,
                        child: _buildExpandedDetails(),
                      ),
                    ],
                  ),
                );
              },
              child:
                  _buildExpandedDetails(), // Pass this down to AnimatedBuilder
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search reports by period... ',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF108DA3)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xFF108DA3)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: _filteredReports.asMap().entries.map(
                    (entry) {
                      return _buildReportCard(context, entry.value, entry.key);
                    },
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> report, int index) {
    final Color primaryColor = const Color(0xFF108DA3);
    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () {
          String reportText = report['report'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportDetailPage(
                  report: reportText, patientid: widget.patientId),
            ),
          );
        },
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.1),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.description_outlined,
            color: primaryColor,
            size: 25,
          ),
        ),
        title: FutureBuilder(
          future: Future.value(
              formatDateTime(report['createdAt'], "dd MMM yyyy • hh:mm a")),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Loading...',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            );
          },
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            color: primaryColor, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, color: Colors.grey[400], size: 100),
              const SizedBox(height: 20),
              const Text(
                "No reports yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Patient reports will show up here once recorded.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDateTime(String dateTimeString, String format) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  return DateFormat(format).format(dateTime);
}
// import 'dart:convert';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:meet_a_doc/services/api_service.dart';
// import 'package:meet_a_doc/services/firebase_service.dart';
// import 'package:meet_a_doc/services/firestore_service.dart';
// import 'package:meet_a_doc/views/doctors_view/nav/patient/report_detail_page.dart';

// class ReportsPage extends StatefulWidget {
//   final dynamic patientId;

//   const ReportsPage({super.key, required this.patientId});

//   @override
//   State<ReportsPage> createState() => _ReportsPageState();
// }

// class _ReportsPageState extends State<ReportsPage> {
//   List<Map<String, dynamic>> _reports = [];
//   List<Map<String, dynamic>> _filteredReports = [];
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     _getReports();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.toLowerCase();

//     setState(() {
//       _filteredReports = _reports.where((report) {
//         final dateTimeString =
//             report['createdAt']; // Assuming this is the field holding the date
//         final DateTime reportDate = DateTime.parse(dateTimeString).toLocal();

//         // Format the date to day and time format
//         final formattedDate = DateFormat('dd MMM yyyy • hh:mm a')
//             .format(reportDate)
//             .toLowerCase();

//         // Check if the formatted date contains the query
//         return formattedDate.contains(query);
//       }).toList();
//     });
//   }

//   Future<void> _getReports() async {
//     List<Map<String, dynamic>> reports = await getReportsforPatient(
//         FirebaseAuth.instance.currentUser!.uid, widget.patientId);
//     setState(() {
//       _reports = reports;
//       _filteredReports = reports;
//     });
//   }

//   Future<String> getPatientName(String patientId) async {
//     final patient = await FirestoreService.getUserData(patientId);
//     return patient['fullName'];
//   }

//   Future<void> _showPatientDetails(String id) async {
//     final details = await getPatientDetails(id);
//     final formatted = const JsonEncoder.withIndent('  ').convert(details);

//     if (!mounted) return;

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: "Patient Details",
//       transitionDuration: const Duration(milliseconds: 300),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return Center(
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               constraints: const BoxConstraints(maxHeight: 500),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 child: Text(
//                   formatted,
//                   style: const TextStyle(fontFamily: 'Courier', fontSize: 14),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
//           child: child,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color primaryColor = const Color(0xFF108DA3);

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: RefreshIndicator(
//         onRefresh: _getReports,
//         color: primaryColor,
//         backgroundColor: Colors.white,
//         child: Column(
//           children: [
//             GestureDetector(
//                 child: _buildTopContainer(context, primaryColor),
//                 onTap: () {
//                   _showPatientDetails(widget.patientId);
//                 }),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search reports by period... ',
//                   prefixIcon:
//                       const Icon(Icons.search, color: Color(0xFF108DA3)),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding:
//                       const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide(color: Color(0xFF108DA3)),
//                   ),
//                 ),
//               ),
//             ),
//             _filteredReports.isEmpty
//                 ? _buildEmptyState()
//                 : Expanded(
//                     child: SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: _filteredReports.asMap().entries.map(
//                           (entry) {
//                             return _buildReportCard(
//                                 context, entry.value, entry.key);
//                           },
//                         ).toList(),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopContainer(BuildContext context, Color primaryColor) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
//       decoration: BoxDecoration(
//         color: primaryColor,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Reports of",
//                 style: TextStyle(
//                   fontSize: 22,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 "click here to view details",
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               FutureBuilder<String>(
//                 future: getPatientName(widget.patientId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Text(
//                       'Loading...',
//                       style: TextStyle(color: Colors.white70),
//                     );
//                   } else if (snapshot.hasError) {
//                     return const Text(
//                       'Error',
//                       style: TextStyle(color: Colors.redAccent),
//                     );
//                   } else {
//                     return Text(
//                       snapshot.data ?? '',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     );
//                   }
//                 },
//               ),
//               SizedBox(
//                 width: 5,
//               ),
//               CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.person,
//                     color: const Color.fromARGB(255, 20, 169, 196),
//                   )),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReportCard(
//       BuildContext context, Map<String, dynamic> report, int index) {
//     final Color primaryColor = const Color(0xFF108DA3);
//     return AnimatedContainer(
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       duration: Duration(milliseconds: 400 + (index * 100)),
//       curve: Curves.easeOutCubic,
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.white,
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           )
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(8),
//         onTap: () {
//           String reportText = report['report'];
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => ReportDetailPage(report: reportText),
//             ),
//           );
//         },
//         leading: Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: primaryColor.withOpacity(0.1),
//           ),
//           padding: const EdgeInsets.all(10),
//           child: Icon(
//             Icons.description_outlined,
//             color: primaryColor,
//             size: 25,
//           ),
//         ),
//         title: FutureBuilder(
//           future: Future.value(
//               formatDateTime(report['createdAt'], "dd MMM yyyy • hh:mm a")),
//           builder: (context, snapshot) {
//             return Text(
//               snapshot.data ?? 'Loading...',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 16,
//               ),
//             );
//           },
//         ),
//         trailing: Icon(Icons.arrow_forward_ios_rounded,
//             color: primaryColor, size: 18),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Expanded(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(40.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.receipt_long, color: Colors.grey[400], size: 100),
//               const SizedBox(height: 20),
//               const Text(
//                 "No reports yet",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Patient reports will show up here once recorded.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// String formatDateTime(String dateTimeString, String format) {
//   final dateTime = DateTime.parse(dateTimeString).toLocal();
//   return DateFormat(format).format(dateTime);
// }
