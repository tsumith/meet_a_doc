import 'package:flutter/material.dart';

import 'package:meet_a_doc/components/navbar.dart';
import 'package:meet_a_doc/views/doctors_view/nav/appointments.dart';
import 'package:meet_a_doc/views/doctors_view/nav/doctor_dash.dart';
import 'package:meet_a_doc/views/doctors_view/nav/patient/patients.dart';
import 'package:meet_a_doc/views/doctors_view/nav/patient/reports.dart';
import 'package:meet_a_doc/views/doctors_view/nav/settings.dart';

class DocHome extends StatefulWidget {
  const DocHome({super.key});

  @override
  State<DocHome> createState() => _DocHomeState();
}

class _DocHomeState extends State<DocHome> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DoctorDashboardPage(),
    PatientsPage(),
    AppointmentsPage(),
    DoctorSettingsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(210, 249, 255, 1),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 205, 249, 255),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
          physics: const BouncingScrollPhysics(),
        ),
      ),
      bottomNavigationBar: BottomNavBarFb2(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
      ),
    );
  }
}
