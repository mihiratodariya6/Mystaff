import 'package:flutter/material.dart';

class ChatConversationScreen extends StatefulWidget {
  final String name;
  const ChatConversationScreen({super.key, required this.name});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello Boss! Aajnu કામ થઈ ગયું છે.", "isMe": false},
    {"text": "સરસ, રીપોર્ટ PDF મોકલી દેજે.", "isMe": true}, // This is dummy data
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          "text": _msgController.text,
          "isMe": true, // We are sending
        });
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name, style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: message['isMe'] ? const Color(0xFF1565C0) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text'], style: TextStyle(color: message['isMe'] ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: "Type message..."))),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Color(0xFF1565C0))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}