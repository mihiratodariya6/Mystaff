import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class StaffDetailsScreen extends StatefulWidget {
  final Map<String, String> staffData;
  final String staffUid; 

  const StaffDetailsScreen({super.key, required this.staffData, required this.staffUid});

  @override
  State<StaffDetailsScreen> createState() => _StaffDetailsScreenState();
}

class _StaffDetailsScreenState extends State<StaffDetailsScreen> {
  int _currentRating = 0; 
  
  bool isRemoteAllowed = false; 
  bool isLoadingPermission = true;

  @override
  void initState() {
    super.initState();
    double initialRating = double.tryParse(widget.staffData['stars'] ?? "0") ?? 0;
    _currentRating = initialRating.round(); 
    
    _fetchPermission(); 
  }

  void _fetchPermission() async {
    if (widget.staffUid.isEmpty) {
      setState(() => isLoadingPermission = false);
      return;
    }
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(widget.staffUid).get();
      if (doc.exists && mounted) {
        setState(() {
          var data = doc.data() as Map<String, dynamic>;
          isRemoteAllowed = data['isRemoteAllowed'] ?? false;
          isLoadingPermission = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingPermission = false);
    }
  }

  void _toggleRemoteWork(bool value) async {
    setState(() => isRemoteAllowed = value);
    try {
      await FirebaseFirestore.instance.collection('employees').doc(widget.staffUid).update({
        'isRemoteAllowed': value,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value ? "Remote Work Enabled ✅" : "Remote Work Disabled 🛑"),
          backgroundColor: value ? Colors.green : Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 🚀 નવું ઉમેર્યું: રેટિંગ ને ફાયરબેઝમાં સેવ કરવાનું લોજીક
  Future<void> _saveRating() async {
    try {
      await FirebaseFirestore.instance.collection('employees').doc(widget.staffUid).update({
        'stars': _currentRating.toString(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rating Saved: $_currentRating Stars! ⭐"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // 🚀 નવું ઉમેર્યું: જે કારીગરની પ્રોફાઈલ હોય એનો જ ફોન નંબર લાગશે
  Future<void> _makeCall() async {
    final String phone = widget.staffData['phone'] ?? "0000000000"; 
    final Uri url = Uri.parse("tel:$phone");
    if (!await launchUrl(url)) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch call")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.staffData['name'] ?? "Staff", style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(radius: 50, backgroundColor: Colors.blue.shade50, child: Text(widget.staffData['name']?[0] ?? "S", style: const TextStyle(fontSize: 40, color: Color(0xFF1565C0), fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Text(widget.staffData['name'] ?? "No Name", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(widget.staffData['role'] ?? "Employee", style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  children: [
                    _buildDetailStat("Present", widget.staffData['present'] ?? "0", Colors.green),
                    _buildDetailStat("Late", widget.staffData['late'] ?? "0", Colors.orange),
                    _buildDetailStat("Absent", widget.staffData['absent'] ?? "0", Colors.red),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.shade200)),
              child: Column(
                children: [
                  const Text("Rate Employee's Performance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < _currentRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 35),
                        onPressed: () => setState(() => _currentRating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _saveRating, // 👈 હવે અહી ફાયરબેઝ વાળું ફંક્શન કોલ થશે
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, elevation: 0),
                    child: const Text("Save Rating", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
              child: isLoadingPermission 
                ? const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
                : SwitchListTile(
                    title: const Text("Allow Field / Remote Work", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("If ON, employee can check-in from anywhere. If OFF, strict 50m office rule applies."),
                    value: isRemoteAllowed,
                    activeColor: Colors.green,
                    onChanged: _toggleRemoteWork,
                  ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn(Icons.call, "Call", Colors.green, _makeCall), // 👈 અહી ફોન વાળું ફંક્શન છે
                const SizedBox(width: 20),
                _actionBtn(Icons.chat, "Chat", Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyStaffChatScreen(staffName: widget.staffData['name'] ?? "Staff")));
                }),
              ],
            ),
            
            const SizedBox(height: 30),
            const Divider(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Attendance History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: DateTime.now(),
                    calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String count, Color color) {
    return Expanded(child: Column(children: [Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))]));
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 26)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class MyStaffChatScreen extends StatefulWidget {
  final String staffName;
  const MyStaffChatScreen({super.key, required this.staffName});
  @override State<MyStaffChatScreen> createState() => _MyStaffChatScreenState();
}
class _MyStaffChatScreenState extends State<MyStaffChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [{"text": "Hello Boss!", "isMe": false}];
  void _sendMessage() { if (_msgController.text.trim().isNotEmpty) { setState(() { _messages.add({"text": _msgController.text, "isMe": true}); _msgController.clear(); }); } }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.staffName, style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15), itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                return Align(
                  alignment: m['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: m['isMe'] ? const Color(0xFF1565C0) : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)), child: Text(m['text'], style: TextStyle(color: m['isMe'] ? Colors.white : Colors.black))),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10), color: Colors.white,
            child: Row(children: [Expanded(child: TextField(controller: _msgController, decoration: const InputDecoration(hintText: "Type message...", border: InputBorder.none))), IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Color(0xFF1565C0)))]),
          ),
        ],
      ),
    );
  }
}