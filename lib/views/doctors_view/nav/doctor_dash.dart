import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:meet_a_doc/services/api_service.dart';
import 'package:meet_a_doc/services/dynamic_link_service.dart'
    as DynamicLinkService;
import 'package:flutter/services.dart';
import 'package:meet_a_doc/services/firestore_service.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  String refCode = " ";
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _reports = [];
  bool loading = true;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Combine initial data loading
  }

  Future<void> _loadInitialData() async {
    // Fetch reports and referral link concurrently
    await Future.wait([
      _getReports(),
      _getReferralLink(),
    ]);

    // Fetch users only after the initial UI is built (or with a delay)
    Future.delayed(Duration.zero, _getUsers);
  }

  Future<void> _getReferralLink() async {
    final uri = await DynamicLinkService.generateDynamicLink(
      FirebaseAuth.instance.currentUser?.uid ?? "",
    );
    setState(() {
      refCode = uri.toString();
    });
  }

  Future<void> _getUsers() async {
    user = await FirestoreService.getUserData(
        FirebaseAuth.instance.currentUser!.uid);

    final users = await FirestoreService.getUsers(
      FirebaseAuth.instance.currentUser?.uid ?? "",
    );
    setState(() {
      _users = users;
    });
  }

  Future<void> _getReports() async {
    final reports = await getReports(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _reports = reports;
      loading = false; // Set loading to false only after reports are fetched
    });
  }

  Future<String> getPatientName(String patientId) async {
    final patient = await FirestoreService.getUserData(patientId);
    return patient['fullName'];
  }

  void _copyReferralLink() async {
    await Clipboard.setData(ClipboardData(text: refCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral link copied to clipboard!')),
    );
  }

  Widget _buildEmptyPatients() {
    return SizedBox(
      height: 140, // Adjust height as needed
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_off, color: Colors.grey[400], size: 40),
              const SizedBox(height: 1),
              const Text(
                "No Patients Yet",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Once patients connect using your referral link, they will appear here.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyReports() {
    return SizedBox(
      height: 400,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, color: Colors.grey[400], size: 80),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 253, 255, 1),
      body: RefreshIndicator(
        color: const Color(0xFF108DA3),
        onRefresh: _getReports,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: loading ? 0.0 : 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(210, 249, 255, 1),
                        Color.fromRGBO(242, 253, 255, 1),
                        Color(0xFFffffff)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 5, 98, 114),
                              Color.fromARGB(255, 139, 211, 223)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.only(
                            top: 60, left: 20, right: 20, bottom: 20),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              child:
                                  Icon(Icons.person, color: Color(0xFF108DA3)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Welcome,\nDr. ${user['fullName']}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Patients - Horizontal Scroll
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Your Patients',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF108DA3),
                                  ),
                            ),
                          ),
                          SizedBox(height: 12),
                          _users.isEmpty
                              ? _buildEmptyPatients()
                              : SizedBox(
                                  height: 167,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _users.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 140,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              blurRadius: 8,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              Colors.grey.shade50,
                                            ],
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE0F2F7),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: const Icon(
                                                  Icons.person_rounded,
                                                  size: 32,
                                                  color: Color(0xFF108DA3)),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              _users[index]['patientName'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Color(0xFF333333)),
                                            ),
                                            const SizedBox(height: 6),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Text(
                                                  'Condition: Stable',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          const SizedBox(height: 24),

                          // Recent Reports
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Reports',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF108DA3),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 44, 44, 44)
                                            .withOpacity(0.10),
                                        blurRadius: 13,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  height: 270,
                                  child: _reports.isEmpty
                                      ? _buildEmptyReports()
                                      : ListView.builder(
                                          itemCount: _reports.length,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              elevation: 0,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.white,
                                                      Colors.grey.shade50,
                                                    ],
                                                  ),
                                                ),
                                                child: ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                  leading: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFE0F2F7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: const Icon(
                                                      Icons.assignment_rounded,
                                                      color: Color(0xFF108DA3),
                                                      size: 28,
                                                    ),
                                                  ),
                                                  title: FutureBuilder<String>(
                                                    future: getPatientName(
                                                        _reports[index]
                                                            ['patientId']),
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        snapshot.data ??
                                                            'Patient',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 17,
                                                            color: Color(
                                                                0xFF333333)),
                                                      );
                                                    },
                                                  ),
                                                  subtitle: Text(
                                                    formatDateTime(
                                                        _reports[index]
                                                            ['createdAt'],
                                                        "dd/MM/yy hh:mm"),
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 13),
                                                  ),
                                                  trailing: Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      size: 18,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        String report =
                                                            _reports[index]
                                                                ['report'];

                                                        return AlertDialog(
                                                          title: const Text(
                                                            'Patient Report',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          content: SizedBox(
                                                            width: double
                                                                .maxFinite,
                                                            child: report == ""
                                                                ? const Text(
                                                                    "No messages recorded.")
                                                                : Scrollbar(
                                                                    thumbVisibility:
                                                                        true,
                                                                    child: Text(
                                                                        report),
                                                                  ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: const Text(
                                                                  'Close'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Copy Referral Link
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                                shadowColor:
                                    const Color.fromARGB(255, 59, 59, 59)
                                        .withOpacity(0.9),
                                backgroundColor: const Color(0xFF108DA3),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _copyReferralLink,
                              icon: const Icon(Icons.link),
                              label: const Text('Copy My Referral Link'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDateTime(String dateTimeString, String format) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  return DateFormat(format).format(dateTime);
}
