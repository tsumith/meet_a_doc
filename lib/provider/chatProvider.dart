import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_a_doc/services/api_service.dart' as ApiService;

class ChatEventProvider extends ChangeNotifier {
  List<dynamic> _chats = [];
  List<dynamic> get chats => _chats;
  Future<void> updateChats() async {
    print("updated chat..........................................");
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // handle if not logged in
    String uid = user.uid;
    _chats = await ApiService.getChats(uid);
    _chats = _chats.reversed.toList();

    notifyListeners();
  }

  void testing() {
    print("working----------------------------------");
    notifyListeners();
  }
}
