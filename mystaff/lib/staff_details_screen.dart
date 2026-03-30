import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffDetailsScreen extends StatefulWidget {
  final Map<String, String> staffData;
  const StaffDetailsScreen({super.key, required this.staffData});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  // 📞 Call Function
  Future<void> _makeCall() async {
    final Uri url = Uri.parse("tel:9924247523");
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch call")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.staffData['name']!)),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 10),
          Text(widget.staffData['name']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionBtn(Icons.call, "Call", Colors.green, _makeCall),
              const SizedBox(width: 20),
              _actionBtn(Icons.chat, "Chat", Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyStaffChatScreen(staffName: widget.staffData['name']!)));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, color: color, size: 30)),
        Text(label),
      ],
    );
  }
}

// 🔥 ACTIVE CHAT SCREEN 🔥
class MyStaffChatScreen extends StatefulWidget {
  final String staffName;
  const MyStaffChatScreen({super.key, required this.staffName});

  @override
  State<MyStaffChatScreen> createState() => _MyStaffChatScreenState();
}

class _MyStaffChatScreenState extends State<MyStaffChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello Boss!", "isMe": false},
  ];

  void _sendMessage() {
    if (_msgController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({"text": _msgController.text, "isMe": true});
        _msgController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.staffName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment: m['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: m['isMe'] ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(m['text'], style: TextStyle(color: m['isMe'] ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: "Type message..."))),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}