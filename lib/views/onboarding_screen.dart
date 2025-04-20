// import 'package:flutter/material.dart';
// import 'home_page.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({Key? key}) : super(key: key);

//   @override
//   _OnboardingScreenState createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   final List<Map<String, dynamic>> _onboardingData = [
//     {
//       'title': 'Find what you need',
//       'description': 'Stay Connected to your doctor.',
//       'icon': Icons.search,
//       'color': Colors.blue,
//     },
//     {
//       'title': 'Know when',
//       'description': 'Schedule appointments at your convenience.',
//       'icon': Icons.calendar_today,
//       'color': Colors.green,
//     },
//     {
//       'title': 'Get Medical Help',
//       'description': 'Access quality care from the comfort of your home.',
//       'icon': Icons.medical_services,
//       'color': Colors.red,
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             PageView.builder(
//               controller: _pageController,
//               onPageChanged: (page) => setState(() => _currentPage = page),
//               itemCount: _onboardingData.length,
//               itemBuilder: (context, index) {
//                 final data = _onboardingData[index];
//                 return OnboardingPage(
//                   title: data['title'],
//                   description: data['description'],
//                   icon: data['icon'],
//                   color: data['color'],
//                 );
//               },
//             ),
//             Positioned(
//               top: 16,
//               right: 20,
//               child: TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const HomePage()),
//                   );
//                 },
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.black87,
//                 ),
//                 child: const Text(
//                   'Skip',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 110,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   _onboardingData.length,
//                   (index) => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(horizontal: 6),
//                     height: 10,
//                     width: _currentPage == index ? 22 : 10,
//                     decoration: BoxDecoration(
//                       color: _currentPage == index
//                           ? Colors.blue
//                           : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               bottom: 40,
//               left: 20,
//               right: 20,
//               child: ElevatedButton(
//                 onPressed: () {
//                   if (_currentPage == _onboardingData.length - 1) {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomePage()),
//                     );
//                   } else {
//                     _pageController.nextPage(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   elevation: 4,
//                   shadowColor: Colors.black26,
//                 ),
//                 child: Text(
//                   _currentPage == _onboardingData.length - 1
//                       ? 'Get Started'
//                       : 'Next',
//                   style: const TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class OnboardingPage extends StatelessWidget {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;

//   const OnboardingPage({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             height: 160,
//             width: 160,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.2),
//                   blurRadius: 30,
//                   offset: const Offset(0, 12),
//                 ),
//               ],
//             ),
//             child: Icon(
//               icon,
//               size: 80,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 50),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.black54,
//               height: 1.4,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Find what you need',
      'description': 'Stay connected to your doctor with ease.',
      'icon': Icons.search,
      'gradient': [Color(0xFF7F00FF), Color(0xFFE100FF)],
    },
    {
      'title': 'Know when',
      'description': 'Schedule appointments at your convenience.',
      'icon': Icons.calendar_today,
      'gradient': [Color(0xFF56CCF2), Color(0xFF2F80ED)],
    },
    {
      'title': 'Get Medical Help',
      'description': 'Access quality care from the comfort of your home.',
      'icon': Icons.medical_services,
      'gradient': [Color(0xFF00C9FF), Color(0xFF92FE9D)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPage(
                  title: data['title'],
                  description: data['description'],
                  icon: data['icon'],
                  gradientColors: data['gradient'],
                );
              },
            ),
            Positioned(
              top: 16,
              right: 20,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    height: 12,
                    width: _currentPage == index ? 28 : 12,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.black87
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == _onboardingData.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 90,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
