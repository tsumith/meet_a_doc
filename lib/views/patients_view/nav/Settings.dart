import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meet_a_doc/services/firebase_service.dart';
import 'package:meet_a_doc/services/firestore_service.dart';
import 'package:meet_a_doc/views/onboarding_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> _userData = {};
  User? user;
  @override
  void initState() {
    super.initState();

    _getData();
  }

  _getData() async {
    user = await FirebaseService.getCurrentUser();
    await FirestoreService.getUserData(user!.uid).then((value) {
      setState(() {
        _userData = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Review your details below",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Info cards
              _infoTile("Username", _userData['fullName'] ?? "",
                  Icons.person_outline),
              _infoTile(
                  "Email", _userData['email'] ?? "", Icons.email_outlined),
              _infoTile("Phone", _userData['phoneNumber'] ?? "",
                  Icons.phone_outlined),
              _infoTile("Doctor’s Referral Code",
                  _userData['referralCode'] ?? "", Icons.qr_code_outlined),

              const Spacer(),

              // Sign Out Button
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10a37f),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OnboardingScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(value),
        leading: Icon(icon),
      ),
    );
  }
}
