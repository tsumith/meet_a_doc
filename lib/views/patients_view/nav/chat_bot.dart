import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_a_doc/components/flutter_magic_button.dart';
import 'package:meet_a_doc/provider/chatProvider.dart';
import 'package:meet_a_doc/services/api_service.dart' as ApiService;
import 'package:meet_a_doc/services/session_service.dart';
import 'package:meet_a_doc/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  final List<_ChatMessage> _messages = []; //messages list
  final TextEditingController _controller =
      TextEditingController(); //text controller
  final ScrollController _scrollController =
      ScrollController(); //scroll controller
  late WebSocketHelper _webSocketHelper;
  bool pressed = false;
  String? doctorId;
  String? sessionId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Key _reportButtonKey = UniqueKey(); /////////////\
  void _clearChatAndResetReportButton() {
    setState(() {
      _messages.clear();
      _controller.clear();
      _reportButtonKey =
          UniqueKey(); // Assign a new UniqueKey to force a new button
    });
  }

  @override
  void initState() {
    super.initState();
    print(
        "ChatScreen initState() called"); ////////////////////////////////////////////////
    sessionId = SessionManager.generateSessionId();
    // Initialize the WebSocket helper with the server URL
    _speech = stt.SpeechToText();
    _connectToWebSocket();
  }

//function for connecting to socket
  void _connectToWebSocket() async {
    //meet-a-doc-server.onrender.com
    _webSocketHelper =
        WebSocketHelper(url: 'wss://meet-a-doc-server.onrender.com');
    _webSocketHelper.connect();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    doctorId = await ApiService.getDoctorId(uid);
    // Connect to the WebSocket server
    // Connect to the WebSocket server
    //listening to the messages
    _webSocketHelper.messages.listen((message) {
      final botMessage = _ChatMessage(
        text: message,
        isUser: false,
        delayed: true,
      );
      setState(() {
        _messages.add(botMessage);
      });
      //newadded--------------------------------------------------------
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }); //-------------------~-----------------------------------------------
    });

    //scroll after the message is received
    // Auto-scroll when a new message comes in
  }

  //// function for sending the generate report signal
  void _sendReport() {
    final reportTriggerMsg = {
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'doctorId': doctorId,
      'text': 'none',
      'sessionId': sessionId,
      'type': 'generate_report',
    };

    _webSocketHelper.sendMessage(jsonEncode(reportTriggerMsg));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating your report...'),
        backgroundColor: Color(0xff10A37F),
      ),
    );
  }

  //////////listing to the key changes for speech to text
  void _listen() async {
    // Request microphone permission
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) {
        print('Microphone permission denied');
        return;
      }
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('STATUS: $status'),
        onError: (error) => print('ERROR: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            print('Recognized words: ${result.recognizedWords}');
            setState(() {
              _text = result.recognizedWords;
              _controller.text = _text;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          },
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  //

  @override
  void dispose() {
    _webSocketHelper.close();

    print("disconnected");
    Provider.of<ChatEventProvider>(context, listen: false)
        .updateChats()
        .then((val) {
      Provider.of<ChatEventProvider>(context, listen: false).testing();
      super.dispose();
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = _ChatMessage(text: text.trim(), isUser: true);
    final msg = {
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'doctorId': doctorId,
      'text': text.trim(),
      'sessionId': sessionId,
      'type': 'none',
    };

    _webSocketHelper.sendMessage(jsonEncode(msg));

    setState(() {
      _messages.add(userMessage);
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff10A37F);
    final user = FirebaseAuth.instance.currentUser;

    return WillPopScope(
      onWillPop: () async {
        bool shouldLeave = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Leave Chat?"),
            content: const Text("without generating a report?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Nope"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yup"),
              ),
            ],
          ),
        );
        return shouldLeave;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xfff7f7f8),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color.fromARGB(255, 9, 114, 88),
                primaryColor,
                const Color.fromARGB(255, 11, 187, 143)
              ]),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.only(
                top: 40, left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.android_rounded,
                      color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chatting with',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Virtual Assistant', // You can customize this name
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  key: _reportButtonKey,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                  child: MagicButton(
                    iconHoverColor: Colors.black,
                    labelHoveredStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: 4,
                    buttonColor: const Color.fromARGB(255, 11, 114, 88),
                    animatingColors: [
                      const Color.fromARGB(255, 35, 151, 113),
                      const Color.fromARGB(255, 81, 245, 168),
                      const Color.fromARGB(255, 172, 255, 223),
                    ],
                    borderRadius: BorderRadius.circular(15),
                    label: pressed ? "report sent " : "send report",
                    icon: Icons.receipt_long_rounded,
                    onPress: () {
                      setState(() {
                        pressed = !pressed;
                      });
                      _sendReport();
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _showConfirmationDialog(context);
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    )),

                // Keep the magic button here
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyChatInstructions()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: _messages[index]);
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: "Ask me anything...",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      !_isListening ? Icons.mic : Icons.mic_off_outlined,
                      color: !_isListening ? primaryColor : Colors.grey,
                    ),
                    onPressed: _listen,
                    color: const Color(0xff10a37f),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(_controller.text),
                    color: const Color(0xff10a37f),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear chat?'),
          content: const Text('Are you sure you want to clear the chat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Yes
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Perform your 'Yes' action here
      _messages.clear(); // Clear the messages list
      _controller.clear(); // Clear the text field
      _clearChatAndResetReportButton();
      // You can call other methods or update state here
    } else if (result == false) {
      // Perform your 'No' action here (or do nothing)
      Navigator.pop(context);
      print('User cancelled (No)');
    } else {
      // Dialog was dismissed in some other way (e.g., tapping outside)

      print('Dialog dismissed');
    }
  }

  Widget _buildEmptyChatInstructions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              " AI Chatbot ",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Start your consultation by letting me know you why you are here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
                height: 60), // Added some space to push instructions up
          ],
        ),
      ),
    );
  }
}

// ------------------ Chat Message Bubble ------------------ //

class ChatBubble extends StatefulWidget {
  final _ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.message.delayed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _opacity = 1.0);
        }
      });
    } else {
      _opacity = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? const Color(0xff10a37f) : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                widget.message.text,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ Message Model ------------------ //

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool delayed;

  _ChatMessage({
    required this.text,
    required this.isUser,
    this.delayed = false,
  });
}
