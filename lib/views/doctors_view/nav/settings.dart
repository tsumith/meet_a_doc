import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meet_a_doc/services/firebase_service.dart';
import 'package:meet_a_doc/services/firestore_service.dart';
import 'package:meet_a_doc/views/onboarding_screen.dart';
import 'package:meet_a_doc/services/dynamic_link_service.dart'
    as DynamicLinkService;

class DoctorSettingsPage extends StatefulWidget {
  const DoctorSettingsPage({super.key});

  @override
  State<DoctorSettingsPage> createState() => _DoctorSettingsPageState();
}

class _DoctorSettingsPageState extends State<DoctorSettingsPage> {
  bool loading = false;
  var _userData;
  String? uid;
  Uri? uri;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    loading = true;
    uid = FirebaseAuth.instance.currentUser!.uid;
    uri = await DynamicLinkService.generateDynamicLink(
        FirebaseAuth.instance.currentUser?.uid ?? "");

    final data = await FirestoreService.getUserData(uid!);
    setState(() {
      _userData = data;
      loading = false;
    });
  }

  void _copyReferralLink(String referralCode) async {
    await Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral link copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF108DA3);

    return Scaffold(
      backgroundColor: const Color(0xfff7f7f8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopContainer(context, primaryColor),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: loading ? 0.07 : 1.0,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile("Full Name", _userData?['fullName'] ?? " ",
                        CupertinoIcons.person),
                    _infoTile("Email", _userData?['email'] ?? " ",
                        CupertinoIcons.mail),
                    _infoTile("Phone", _userData?['phoneNumber'] ?? " ",
                        CupertinoIcons.phone),
                    _infoTile(
                        "License Number",
                        _userData?['licenseNumber'] ?? " ",
                        CupertinoIcons.checkmark_shield),
                    _infoTile(
                        "Specialization",
                        _userData?['specialization'] ?? " ",
                        CupertinoIcons.briefcase),
                    _infoTile("Referral Code",
                        _userData?['referralCode'] ?? " ", CupertinoIcons.link),
                    const SizedBox(height: 24),
                    _iosButton(
                      icon: CupertinoIcons.link,
                      text: "Copy Referral Link",
                      color: primaryColor,
                      onPressed: () => _copyReferralLink(uri.toString()),
                    ),
                    const SizedBox(height: 16),
                    _iosButton(
                      icon: CupertinoIcons.arrow_right_square,
                      text: "Sign Out",
                      color: Colors.redAccent,
                      onPressed: () async {
                        await FirebaseService.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OnboardingScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainer(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Color.fromARGB(255, 5, 98, 114),
          Color.fromARGB(255, 139, 211, 223)
        ]),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Doctor Profile",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Manage your profile and referral details",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF108DA3),
            size: 26,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iosButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 15),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
          elevation: 5,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
