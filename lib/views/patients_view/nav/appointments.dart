// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:meet_a_doc/services/api_service.dart';

// class Appointments extends StatefulWidget {
//   @override
//   State<Appointments> createState() => _AppointmentsState();
// }

// class _AppointmentsState extends State<Appointments> {
//   List<Map<String, dynamic>> _appointments = [];
//   final patientId = FirebaseAuth.instance.currentUser!.uid;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _getAppointments();
//   }

//   void _createAppointments() async {
//     final doctorId = await getDoctorId(patientId);
//     await createAppointsment(doctorId, patientId);
//     _getAppointments(); // refresh after creating
//   }

//   void _getAppointments() async {
//     final appointments = await getAppointsmentsForPatients(patientId);
//     setState(() {
//       _appointments = appointments;
//       _isLoading = false;
//     });
//   }

//   Future<void> _onRefresh() async {
//     _getAppointments(); // placeholder logic
//   }

//   Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
//     return GestureDetector(
//       onTap: () {},
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ],
//           border: Border.all(color: const Color(0xff10A37F).withOpacity(0.2)),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//         child: ListTile(
//           leading: CircleAvatar(
//               backgroundColor: const Color(0xff10A37F),
//               child: Icon(
//                 Icons.receipt,
//                 color: Colors.white,
//               )),
//           title: Text(
//             appointment['date'] != null
//                 ? formatDateTime(appointment['date'], "yyyy-MM-dd hh:mm")
//                 : "pending",
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//           subtitle: Text(
//             "status: ${appointment['status']}\n"
//             "created at: ${formatDateTime(appointment['createdAt'], "yyyy-MM-dd hh:mm")}\n"
//             "id:${appointment['_id']}",
//             style: const TextStyle(color: Color.fromARGB(255, 107, 107, 107)),
//           ),
//           isThreeLine: true,
//           trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyAppointments() {
//     return SliverFillRemaining(
//       hasScrollBody: false,
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(40.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.calendar_today, color: Colors.grey[400], size: 80),
//               const SizedBox(height: 20),
//               const Text(
//                 "No appointments yet",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Your appointment requests will appear here once created.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Create Appointment Request"),
//         content: const Text("Sure, want to create a request for appointment?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text("No"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _createAppointments();
//             },
//             child: const Text("Yes"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xff10A37F)))
//           : RefreshIndicator(
//               onRefresh: _onRefresh,
//               child: CustomScrollView(
//                 slivers: _appointments.isEmpty
//                     ? [_buildEmptyAppointments()]
//                     : [
//                         SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) =>
//                                 _buildAppointmentCard(_appointments[index]),
//                             childCount: _appointments.length,
//                           ),
//                         ),
//                       ],
//               ),
//             ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xff10A37F),
//         onPressed: _showConfirmationDialog,
//         child: const Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// String formatDateTime(String dateTimeString, String format) {
//   final dateTime = DateTime.parse(dateTimeString).toLocal();
//   return DateFormat(format).format(dateTime);
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_a_doc/services/api_service.dart';

class Appointments extends StatefulWidget {
  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  List<Map<String, dynamic>> _appointments = [];
  final patientId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAppointments();
  }

  void _createAppointments() async {
    final doctorId = await getDoctorId(patientId);
    await createAppointsment(doctorId, patientId);
    _getAppointments(); // refresh after creating
  }

  void _getAppointments() async {
    final appointments = await getAppointsmentsForPatients(patientId);
    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    _getAppointments(); // placeholder logic
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
          border: Border.all(
              color: _getStatusColor(appointment['status']).withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(appointment['status']),
            child: const Icon(
              Icons.receipt,
              color: Colors.white,
            ),
          ),
          title: Text(
            appointment['date'] != null
                ? formatDateTime(appointment['date'], "yyyy-MM-dd hh:mm")
                : "pending",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            "status: ${appointment['status']}\n"
            "created at: ${formatDateTime(appointment['createdAt'], "yyyy-MM-dd hh:mm")}\n"
            "id:${appointment['_id']}",
            style: const TextStyle(color: Color.fromARGB(255, 107, 107, 107)),
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyAppointments() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[400], size: 80),
              const SizedBox(height: 20),
              const Text(
                "No appointments yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Your appointment requests will appear here once created.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Appointment Request"),
        content: const Text("Sure, want to create a request for appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createAppointments();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return const Color(0xFF108DA3);
      case 'confirmed':
        return Colors.green;
      case 'declined':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  PreferredSizeWidget _myappBar() {
    const primaryColor = Color(0xff10A37F);
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color.fromARGB(255, 9, 114, 88),
            primaryColor,
            const Color.fromARGB(255, 11, 187, 143)
          ]),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.only(
            top: 50, left: 16.0, right: 16.0, bottom: 16.0),
        child: Row(
          children: [
            const SizedBox(width: 4),
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.calendar_month_outlined,
                  color: primaryColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    "appointments",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
                width:
                    48), // Added some spacing where the notification icon was
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _myappBar(),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff10A37F)))
          : RefreshIndicator(
              backgroundColor: Colors.white,
              color: Color(0xff10A37F),
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: _appointments.isEmpty
                    ? [_buildEmptyAppointments()]
                    : [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildAppointmentCard(_appointments[index]),
                            childCount: _appointments.length,
                          ),
                        ),
                      ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff10A37F),
        onPressed: _showConfirmationDialog,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

String formatDateTime(String dateTimeString, String format) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  return DateFormat(format).format(dateTime);
}
