import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth_view/patient_login.dart';
import '../auth_view/doctor_login.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FEFF),
      body: Column(
        children: [
          // Header with gradient and illustration
          Container(
            width: double.infinity,
            height: size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF108DA3), Color(0xFF8BD3DF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.health_and_safety_rounded,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  'Meet a Doc',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your health journey starts here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                AnimatedLoginButton(
                  label: "I am a Patient",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PatientLoginPage(),
                      ),
                    );
                  },
                  color: const Color(0xFF108DA3),
                  icon: Icons.favorite_outline,
                ),
                const SizedBox(height: 20),
                AnimatedLoginButton(
                  label: "I am a Doctor",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DoctorLoginPage(),
                      ),
                    );
                  },
                  color: const Color(0xFF0E5965),
                  icon: Icons.medical_services_outlined,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Branding
        ],
      ),
    );
  }
}

class AnimatedLoginButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final IconData icon;

  const AnimatedLoginButton({
    Key? key,
    required this.label,
    required this.onTap,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
