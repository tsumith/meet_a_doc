
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  // Sign Up
  static Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign In
  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  static Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
