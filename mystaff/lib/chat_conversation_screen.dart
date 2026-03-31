import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChatConversationScreen extends StatefulWidget {
  final String name; // 👈 કોની સાથે વાત થાય છે એનું નામ
  const ChatConversationScreen({super.key, required this.name});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  
  String companyCode = "";
  String currentUserName = "Loading...";
  String currentUserRole = "employee";
  String currentUid = "";

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 👈 એપ ખુલતા જ યુઝરનો ડેટા ખેંચી લાવશે
  }

  // 📥 મેમરીમાંથી ચેક કરશે કે આ બોસ છે કે એમ્પ્લોઈ?
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      companyCode = prefs.getString('company_code') ?? "";
      currentUserRole = prefs.getString('user_role') ?? "employee";
    });
    
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUid = user.uid;
      
      if (currentUserRole == 'boss') {
         // જો બોસ હશે તો એનું નામ 'Boss' રાખશે
         setState(() => currentUserName = "Boss / Admin 👑");
      } else {
         // જો એમ્પ્લોઈ હશે તો ડેટાબેઝમાંથી એનું અસલી નામ લાવશે
         DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(currentUid).get();
         if(doc.exists && mounted) setState(() => currentUserName = doc['name']);
      }
    }
  }

  // 🚀 લાઈવ મેસેજ મોકલવાનું જાદુઈ ફંક્શન
  void _sendMessage() async {
    String text = _msgController.text.trim();
    if (text.isEmpty || companyCode.isEmpty) return; // ખાલી મેસેજ નહિ જાય

    _msgController.clear(); // મેસેજ લખ્યા પછી બોક્સ ખાલી થઈ જશે

    // ☁️ સીધું ગૂગલના સર્વરમાં મેસેજ સેવ થશે
    await FirebaseFirestore.instance
      .collection('company_chats')
      .doc(companyCode)
      .collection('messages')
      .add({
        'text': text,
        'senderId': currentUid,
        'senderName': currentUserName,
        'role': currentUserRole,
        'timestamp': FieldValue.serverTimestamp(),
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // WhatsApp જેવું બેકગ્રાઉન્ડ
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.orange.shade100, child: const Icon(Icons.business, color: Colors.orange)),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("Company Group Chat", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      
      body: Column(
        children: [
          // 💬 ૧. મેસેજ બતાવવા વાળો મોટો એરિયા (StreamBuilder)
          Expanded(
            child: companyCode.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  // ડેટાબેઝમાંથી ટાઈમ પ્રમાણે મેસેજ લાઈવ લાવશે 
                  stream: FirebaseFirestore.instance
                      .collection('company_chats')
                      .doc(companyCode)
                      .collection('messages')
                      .orderBy('timestamp', descending: true) // નવો મેસેજ નીચે આવશે
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages yet. Say Hi! 👋", style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.builder(
                      reverse: true, // WhatsApp ની જેમ લિસ્ટ નીચેથી ઉપર જશે
                      padding: const EdgeInsets.all(15),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var msg = snapshot.data!.docs[index];
                        bool isMe = msg['senderId'] == currentUid; // આ મેસેજ મેં મોકલ્યો છે કે બીજાએ?

                        // ટાઈમ ફોર્મેટિંગ
                        String msgTime = "";
                        if (msg['timestamp'] != null) {
                          msgTime = DateFormat('hh:mm a').format((msg['timestamp'] as Timestamp).toDate());
                        }

                        return _buildMessageBubble(
                          text: msg['text'],
                          senderName: msg['senderName'],
                          time: msgTime,
                          isMe: isMe,
                          isBoss: msg['role'] == 'boss'
                        );
                      },
                    );
                  },
              ),
          ),

          // ⌨️ ૨. નીચે મેસેજ લખવાનું બોક્સ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)]),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.attach_file, color: Colors.grey), onPressed: (){}),
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (value) => _sendMessage(), // Enter દબાવે તોય જાય
                    ),
                  ),
                  const SizedBox(width: 5),
                  // 🚀 ગોળ સેન્ડ બટન
                  GestureDetector(
                    onTap: _sendMessage,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF1565C0),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // 🎨 મેસેજના ફુગ્ગા (Bubbles) ની ડિઝાઇન
  Widget _buildMessageBubble({required String text, required String senderName, required String time, required bool isMe, required bool isBoss}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 10, right: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
          ),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // જો મેસેજ સામે વાળાનો હોય, તો એનું નામ બતાવશે
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  senderName, 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isBoss ? Colors.orange.shade700 : Colors.blue.shade700)
                ),
              ),
            // અસલી મેસેજ
            Text(text, style: TextStyle(fontSize: 15, color: isMe ? Colors.white : Colors.black87)),
            const SizedBox(height: 5),
            // ટાઈમ 
            Align(
              alignment: Alignment.bottomRight,
              child: Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}