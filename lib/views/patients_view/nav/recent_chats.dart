import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EachChatView extends StatelessWidget {
  final dynamic chat;
  const EachChatView({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final messages = chat['messages'] ?? [];
    final report = chat['report'] ?? 'No report available';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text('Chat History'),
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 20),
              child: Text(
                  "${formatDateTime(chat['createdAt'], 'dd/MM/yyyy hh:mm a')}"))
        ],
      ),
      body: Column(
        children: [
          // Messages Section
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['isUser'] == true;
                final text = message['text'] ?? '';

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Color.fromARGB(255, 255, 218, 148)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isUser
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String formatDateTime(String dateTimeString, String format) {
  final dateTime = DateTime.parse(dateTimeString).toLocal();
  return DateFormat(format).format(dateTime);
}
