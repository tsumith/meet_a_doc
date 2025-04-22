import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet_a_doc/services/api_service.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> filteredAppointments = [];
  bool loading = true;
  String selectedStatus = 'Pending';
  final List<String> statusFilters = ['Pending', 'Confirmed', 'Declined'];

  @override
  void initState() {
    super.initState();
    _getAppoints();
  }

  Future<void> _getAppoints() async {
    final docId = FirebaseAuth.instance.currentUser!.uid;
    final data = await getAppointsmentsForDoctors(docId);
    setState(() {
      appointments = data;
      _filterAppointments();
      loading = false;
    });
  }

  void _filterAppointments() {
    setState(() {
      filteredAppointments = appointments
          .where((appointment) =>
              appointment['status']?.toString().toLowerCase() ==
              selectedStatus.toLowerCase())
          .toList();
    });
  }

  void _handleToggle(String status) {
    setState(() {
      selectedStatus = status;
      _filterAppointments();
    });
  }

  void _handleAppointmentTap(int index) async {
    final appointment = filteredAppointments[index];
    if (appointment['status'] == 'Pending') {
      final shouldAccept = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accept Appointment'),
          content: Text(
              'Do you want to accept the appointment for ${appointment['patient']}?'),
          actions: [
            TextButton(
              onPressed: () =>
                  _updateAppointmentStatus(appointment, 'Declined'),
              child: const Text('Decline'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 10, minute: 0),
                  );

                  if (pickedTime != null) {
                    final formattedDate =
                        "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                    final formattedTime = pickedTime.format(context);
                    final updatedDate =
                        _convertToDate("$formattedDate $formattedTime");

                    _updateAppointmentStatus(appointment, 'Confirmed',
                        updatedDate: updatedDate);
                  }
                }
              },
              child: const Text('Accept'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _updateAppointmentStatus(
      Map<String, dynamic> appointment, String newStatus,
      {DateTime? updatedDate}) async {
    print(appointment);
    setState(() {
      appointment['status'] = newStatus;
      if (updatedDate != null) {
        appointment['date'] = updatedDate;
      } else {
        appointment['date'] = DateTime.now();
      }
      _filterAppointments();
    });
    Navigator.pop(context);
    await _sendDate(appointment);
  }

  _sendDate(Map<String, dynamic> appointment) async {
    await setDatetoAppointment(appointment);
  }

  _convertToDate(String date) {
    final format = DateFormat('M/d/yyyy h:mm a');
    return format.parse(date);
  }

  Future<void> _refreshAppointments() async {
    await _getAppoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 254, 255),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: loading ? 0.0 : 1.0,
        child: Column(
          children: [
            _buildTopContainer(),
            const SizedBox(height: 12),
            _buildToggleButtons(),
            const SizedBox(height: 16),
            filteredAppointments.isEmpty
                ? _buildEmpty()
                : Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF108DA3),
                      onRefresh: _refreshAppointments,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredAppointments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final appointment = filteredAppointments[index];
                          return _buildAppointmentCard(index, appointment);
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: statusFilters.map((status) {
        final isSelected = selectedStatus == status;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ChoiceChip(
            checkmarkColor: Colors.white,
            backgroundColor: Colors.white,
            label: Text(status),
            selected: isSelected,
            selectedColor: const Color(0xFF108DA3),
            onSelected: (_) => _handleToggle(status),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<String>? getPatientname(String id) async {
    final patient = await getPatientName(id);
    return patient['patientName'];
  }

  Widget _buildAppointmentCard(int index, Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () => _handleAppointmentTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4),
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
              color: const Color.fromARGB(255, 16, 153, 163).withOpacity(0.15)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(appointment['status']),
            child: FutureBuilder<String>(
              future: getPatientname(appointment['patientId']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    'U',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }
                return Text(
                  snapshot.data!.toUpperCase().substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ),
          title: FutureBuilder<String>(
            future: getPatientname(appointment['patientId']),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Unknown Patient',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              );
            },
          ),
          subtitle: Text(
            "on: ${appointment['date'] == null ? "pending" : DateFormat('MMM dd-yyyy hh:mm a').format(DateTime.parse(appointment['date'].toString()))} \n"
            "Status: ${appointment['status'] ?? 'Pending'}\n"
            "created: ${appointment['createdAt'].substring(0, 10)} ",
            style: const TextStyle(color: Color.fromARGB(255, 49, 49, 49)),
          ),
          isThreeLine: true,
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
        ),
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

  Widget _buildTopContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 5, 98, 114),
          Color.fromARGB(255, 139, 211, 223),
        ]),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Appointments",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Upcoming and past patient appointments",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.meeting_room_outlined,
                  color: Colors.grey[400], size: 80),
              const SizedBox(height: 20),
              const Text(
                "No appointments",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Appointments will show up here once requested.",
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
