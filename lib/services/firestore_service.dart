import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> createUserDocument({
    required String uid,
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    print("connection successful for firestore");
    // Validate role is either 'doctor' or 'patient'
    if (role != 'doctor' && role != 'patient') {
      throw Exception('Invalid role. Must be either "doctor" or "patient"');
    }

    // Add role to user data
    userData['role'] = role;

    // Create/update user document
    await _firestore.collection('users').doc(uid).set(
          userData,
          SetOptions(merge: true),
        );
  }

  // Get user role
  static Future<String?> getUserRole(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?['role'] as String?;
    }
    return null;
  }

  // Add patient to doctor's patients list
  static Future<void> addPatientToDoctor({
    required String doctorId,
    required String patientId,
    required String patientName,
    required String patientEmail,
  }) async {
    try {
      final doctorDoc =
          await _firestore.collection('users').doc(doctorId).get();
      if (!doctorDoc.exists || doctorDoc.data()?['role'] != 'doctor') {
        throw Exception('Invalid doctor ID');
      }

      // Add patient to doctor's patients collection
      await _firestore
          .collection('users')
          .doc(doctorId)
          .collection('patients')
          .add({
        'patientId': patientId,
        'patientName': patientName,
        'patientEmail': patientEmail
      });
    } catch (e) {
      throw Exception('Failed to add patient to doctor: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getUsers(String uid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('patients')
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  static Future<Map<String, dynamic>> getUserData(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    }
    return {};
  }

  static Future<void> addReferralCode(String uid, String referralCode) async {
    await _firestore.collection('referralCodes').add({
      'doctorId': uid,
      'referralCode': referralCode,
    });
  }

  static Future<String> checkReferralCode(String referralCode) async {
    final QuerySnapshot querySnapshot = await _firestore
        .collection('referralCodes')
        .where('referralCode', isEqualTo: referralCode.trim())
        .limit(1)
        .get();
    print("referralCode: $referralCode");
    print(querySnapshot.docs.first.get('doctorId'));

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('doctorId') as String;
    } else {
      return '';
    }
  }
}
