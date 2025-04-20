// import 'package:flutter/material.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:meet_a_doc/auth_view/patient_login.dart';
// import '../services/firebase_service.dart';
// import '../services/firestore_service.dart';

// class PatientRegisterPage extends StatefulWidget {
//   final String? referralCode;
//   const PatientRegisterPage({Key? key, required this.referralCode})
//       : super(key: key);

//   @override
//   _PatientRegisterPageState createState() => _PatientRegisterPageState();
// }

// class _PatientRegisterPageState extends State<PatientRegisterPage> {
//   String? referralCode;

//   @override
//   void initState() {
//     super.initState();
//     referralCode = widget.referralCode;
//     _setReferralCode();
//   }

//   void _setReferralCode() {
//     if (referralCode != null && referralCode!.length > 6) {
//       setState(() {
//         _referralCodeController.text = referralCode!.substring(0, 6);
//       });
//     }
//   }

//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _fullNameController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _referralCodeController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _fullNameController.dispose();
//     _phoneNumberController.dispose();
//     _referralCodeController.dispose();
//     super.dispose();
//   }

//   Future<void> _signUp() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       try {
//         // Create user in Firebase Auth
//         await FirebaseService.signUp(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//         );

//         // Get the current user
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           // Create patient document in Firestore
//           await FirestoreService.createUserDocument(
//             uid: user.uid,
//             role: 'patient',
//             userData: {
//               'fullName': _fullNameController.text.trim(),
//               'email': _emailController.text.trim(),
//               'phoneNumber': _phoneNumberController.text.trim(),
//               'referralCode': _referralCodeController.text.trim(),
//             },
//           ).then((val) async {
//             await FirestoreService.addPatientToDoctor(
//               doctorId: referralCode!.substring(3),
//               patientId: user.uid,
//             );
//           });

//           // Navigate to patient dashboard
//           Navigator.push(context, MaterialPageRoute(builder: (context) {
//             return PatientLoginPage();
//           }));
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Patient Registration'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _fullNameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Confirm Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your password';
//                   }
//                   if (value != _passwordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _phoneNumberController,
//                 decoration: const InputDecoration(
//                   labelText: 'Phone Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _referralCodeController,
//                 enabled: referralCode == null,
//                 decoration: InputDecoration(
//                   labelText: "Doctors referral id",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter referral code';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _signUp,
//                   child: _isLoading
//                       ? const CircularProgressIndicator()
//                       : const Text('Register'),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                     return PatientLoginPage();
//                   }));
//                 },
//                 child: const Text('Already have an account? Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meet_a_doc/auth_view/patient_login.dart';
import 'package:meet_a_doc/infopages/patient_info.dart';
import 'package:meet_a_doc/services/api_service.dart';

import '../services/firebase_service.dart';
import '../services/firestore_service.dart';

class PatientRegisterPage extends StatefulWidget {
  final String? referralCode;
  const PatientRegisterPage({Key? key, required this.referralCode})
      : super(key: key);

  @override
  _PatientRegisterPageState createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  String? referralCode;

  @override
  void initState() {
    super.initState();
    referralCode = widget.referralCode;
    print("referralCode:----------------------------- $referralCode");

    _setReferralCode();
  }

  void _setReferralCode() {
    if (referralCode != null && referralCode!.length > 6) {
      setState(() {
        _referralCodeController.text = referralCode!.substring(0, 8);
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _referralCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = FirebaseAuth.instance.currentUser;

        final docid = await FirestoreService.checkReferralCode(
            _referralCodeController.text.trim());
        print(
            "$docid ------------********------------- ${_referralCodeController.text}");
        if (user != null) {
          if (docid != '') {
            if (_referralCodeController.text == 'DR${docid.substring(0, 6)}') {
              await FirestoreService.createUserDocument(
                uid: user.uid,
                role: 'patient',
                userData: {
                  'fullName': _fullNameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'phoneNumber': _phoneNumberController.text.trim(),
                  'referralCode': _referralCodeController.text.trim(),
                },
              ).then((val) async {
                await FirestoreService.addPatientToDoctor(
                  doctorId: docid,
                  patientId: user.uid,
                  patientName: _fullNameController.text.trim(),
                  patientEmail: _emailController.text.trim(),
                );
                await registerPatient({
                  'id': user.uid,
                  'fullName': _fullNameController.text.trim(),
                  'email': _emailController.text.trim(),
                  'phoneNumber': _phoneNumberController.text.trim(),
                  'referralCode': referralCode!.substring(2),
                }).then((onValue) async {
                  await addPatientsToDoctor(docid, user.uid).then((val) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PatientDetailsPage()),
                    );
                  });
                });
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid referral code')),
              );
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff10A37F);
    const backgroundColor = Color(0xfff7f7f8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Patient Registration'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Register to get started",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInput(_fullNameController, "Full Name", Icons.person),
                  const SizedBox(height: 16),
                  _buildInput(_emailController, "Email", Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildInput(
                      _passwordController, "Password", Icons.lock_outline,
                      obscureText: true),
                  const SizedBox(height: 16),
                  _buildInput(_confirmPasswordController, "Confirm Password",
                      Icons.lock_outline,
                      obscureText: true),
                  const SizedBox(height: 16),
                  _buildInput(_phoneNumberController, "Phone Number",
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildInput(
                    _referralCodeController,
                    "Doctor's Referral ID",
                    Icons.card_giftcard,
                    enabled: referralCode == null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (referralCode == null) {
                                referralCode =
                                    _referralCodeController.text.trim();
                              }
                              _signUp();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Register'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PatientLoginPage()),
                      );
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xfff7f7f8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label'.toLowerCase();
        }
        if (label == "Password" && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label == "Confirm Password" && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
