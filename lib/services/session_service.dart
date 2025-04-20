import 'package:uuid/uuid.dart';

class SessionManager {
  static final _uuid = Uuid();

  // Method to generate and return a new session ID
  static String generateSessionId() {
    return _uuid.v4();  // Generates a unique session ID (UUID)
  }
}