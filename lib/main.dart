// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:meet_a_doc/auth_view/patient_register.dart';
// import 'package:meet_a_doc/firebase_options.dart';
// import 'package:meet_a_doc/provider/chatProvider.dart';
// import 'package:meet_a_doc/services/firestore_service.dart';
// import 'package:meet_a_doc/views/doctors_view/doc_home.dart';

// import 'package:meet_a_doc/views/onboarding_screen.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:meet_a_doc/views/patients_view/patient_dash.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(MultiProvider(
//     providers: [
//       ChangeNotifierProvider(create: (context) => ChatEventProvider())
//     ],
//     child: MyApp(),
//   ));
// }

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AppEntryPoint(),
//       title: 'Meet a Doc',
//       theme: ThemeData(
//         listTileTheme: ListTileThemeData(
//             tileColor: Colors.white,
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20))),
//         // listTileTheme: ListTileThemeData(tileColor: Colors.white,),
//         cardColor: Colors.white,
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: const Color(0xff10a37f),
//           ),
//         ),
//         floatingActionButtonTheme: FloatingActionButtonThemeData(
//           foregroundColor: Colors.white,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xff10a37f),
//             foregroundColor: Colors.white,
//           ),
//         ),
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       // onGenerateRoute: Routes.generateRoute,
//     );
//   }
// }

// class AppEntryPoint extends StatefulWidget {
//   const AppEntryPoint({super.key});

//   @override
//   State<AppEntryPoint> createState() => _AppEntryPointState();
// }

// class _AppEntryPointState extends State<AppEntryPoint> {
//   @override
//   void initState() {
//     super.initState();
//         _checkUserAndNavigate();

//   }

//   void _checkUserAndNavigate() async {
//     final user = await FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userRole = await FirestoreService.getUserRole(user.uid);
//       if (userRole == 'patient') {
//         Navigator.pushReplacement(context,
//             MaterialPageRoute(builder: (context) => const PatientHomePage()));
//       } else if (userRole == 'doctor') {
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => const DocHome()));
//       } else {
//         _initDynamicLinks();
//       }
//     }
//   }

//   void _initDynamicLinks() async {
//     final PendingDynamicLinkData? initialLink =
//         await FirebaseDynamicLinks.instance.getInitialLink();

//     _handleDeepLink(initialLink?.link);

//     FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
//       _handleDeepLink(dynamicLinkData.link);
//     });
//   }

//   void _handleDeepLink(Uri? deepLink) {
//     if (deepLink != null) {
//       final referralCode = deepLink.queryParameters['ref'];
//       if (referralCode != null) {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) =>
//                     PatientRegisterPage(referralCode: referralCode)));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return  OnboardingScreen(); // or whatever your onboarding screen is
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meet_a_doc/auth_view/patient_register.dart';
import 'package:meet_a_doc/firebase_options.dart';
import 'package:meet_a_doc/provider/chatProvider.dart';
import 'package:meet_a_doc/services/firestore_service.dart';
import 'package:meet_a_doc/views/doctors_view/doc_home.dart';
import 'package:meet_a_doc/views/onboarding_screen.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_a_doc/views/patients_view/patient_dash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ChatEventProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AppEntryPoint(),
      title: 'Meet a Doc',
      theme: ThemeData(
        listTileTheme: ListTileThemeData(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        cardColor: Colors.white,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xff10a37f),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff10a37f),
            foregroundColor: Colors.white,
          ),
        ),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isHandlingDeepLink = false;

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    // Delay slightly to allow dynamic link handling to potentially set state
    await Future.delayed(const Duration(milliseconds: 200));

    if (_isHandlingDeepLink) {
      return; // Don't navigate again if a deep link is being processed
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRole = await FirestoreService.getUserRole(user.uid);
      if (userRole == 'patient') {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const PatientHomePage()));
        }
      } else if (userRole == 'doctor') {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DocHome()));
        }
      } else {
        // User logged in but no role, might need to handle this case
        if (mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const OnboardingScreen()));
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()));
      }
    }
  }

  Future<void> _initDynamicLinks() async {
    FirebaseDynamicLinks.instance.getInitialLink().then((initialLink) {
      _handleDeepLink(initialLink?.link);
    });

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDeepLink(dynamicLinkData.link);
    }).onError((error) {
      // Handle errors
      print('Dynamic Link Error: $error');
    });
  }

  void _handleDeepLink(Uri? deepLink) {
    if (deepLink != null && !_isHandlingDeepLink) {
      setState(() {
        _isHandlingDeepLink = true;
      });
      final referralCode = deepLink.queryParameters['ref'];
      if (referralCode != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PatientRegisterPage(referralCode: referralCode)),
          ).then((_) {
            setState(() {
              _isHandlingDeepLink = false;
            });
          });
        } else {
          setState(() {
            _isHandlingDeepLink = false;
          });
        }
      } else {
        setState(() {
          _isHandlingDeepLink = false;
        });
        // No referral code, might navigate to onboarding directly if not logged in
        _checkUserAndNavigate(); // Re-check user and navigate
      }
    } else if (deepLink == null && !_isHandlingDeepLink) {
      _checkUserAndNavigate(); // Check user and navigate if no initial link
    }
  }

  @override
  Widget build(BuildContext context) {
    return const OnboardingScreen();
  }
}
