import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_a_doc/components/flutter_magic_button.dart';
import 'package:meet_a_doc/views/doctors_view/nav/appointments.dart';
import 'package:meet_a_doc/views/patients_view/nav/appointments.dart';
import 'package:meet_a_doc/views/patients_view/nav/reports.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:meet_a_doc/views/patients_view/nav/chat_bot.dart';
import 'package:meet_a_doc/views/patients_view/nav/Settings.dart';
import '../../provider/chatProvider.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ChatEventProvider>(context, listen: false).updateChats();
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToChatBot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen()),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff10A37F);
    const backgroundColor = Color(0xfff7f7f8);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color.fromARGB(255, 9, 114, 88),
              primaryColor,
              const Color.fromARGB(255, 11, 187, 143)
            ]),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
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
              top: 40, left: 16.0, right: 16.0, bottom: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: _openDrawer, // Open the drawer on press
              ),
              const SizedBox(width: 4),
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      user?.email?.split('@')[0] ?? "User",
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
      ),
      drawer: _buildDrawer(context), // Keep the drawer
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        color: primaryColor,
        onRefresh: () async {
          await Provider.of<ChatEventProvider>(context, listen: false)
              .updateChats();
        },
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            Consumer<ChatEventProvider>(
              builder: (context, provider, _) {
                final chats = provider.chats;
                return CustomScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Make it always scrollable
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody:
                          false, // To make it behave like a SingleChildScrollView
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildQuickActions(primaryColor),
                            const SizedBox(height: 20),
                            _buildRecentChats(chats),
                            const SizedBox(height: 20),
                            _buildHealthTips(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Appointments(),
            SettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'meets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Consumer<ChatEventProvider>(
      builder: (context, prov, child) {
        var chats = prov.chats;
        return Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Recent Chats', // Changed title to match the request
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.chat_bubble_outline,
                          color: Colors.teal), // Added an icon
                      title: Text(
                        "Chat at ${formatDateTime(chats[index]['createdAt'], "dd/MM/yy hh:mm a")}",
                      ),
                      subtitle: const Text('Tap to open chat'),
                      onTap: () {
                        // Handle chat tap - you might want to navigate to the specific chat
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner() {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Colors.teal, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Welcome back,  👋\nLet’s keep your health on track today!",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color primaryColor) {
    return Row(
      children: [
        _buildActionCard(
          icon: Icons.chat,
          label: "New Chat",
          color: primaryColor,
          onTap: _navigateToChatBot,
        ),
        const SizedBox(width: 16),
        _buildActionCard(
          icon: Icons.receipt_long,
          label: "Reports",
          color: Colors.orange,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (cont) => PatientsReportPage()));
            // Add navigation to reports page
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentChats(List chats) {
    if (chats.isEmpty) {
      return const Text("No recent chats yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Chats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...chats.take(3).map((chat) {
          return Card(
            shadowColor: const Color.fromARGB(255, 75, 75, 75),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.message_outlined, color: Colors.teal),
              title: Text(
                  "on ${formatDateTime(chat['createdAt'], "dd-MM-yy hh:mm a")}"),
              subtitle: const Text("Tap to view full conversation"),
              onTap: () {
                // Handle navigation to the specific chat
              },
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHealthTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Health Tips",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "💧 Stay hydrated! Drink at least 8 glasses of water today.",
            style: TextStyle(fontSize: 15),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            "🧘‍♀️ Take 10 minutes to relax and breathe deeply. Your mind matters.",
            style: TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

String formatDateTime(String dateTimeString, String format) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  return DateFormat(format).format(dateTime);
}
