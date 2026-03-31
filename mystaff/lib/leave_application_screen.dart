import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LeaveApplicationScreen extends StatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  State<LeaveApplicationScreen> createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? selectedDate;
  bool isSubmitting = false;

  String companyCode = "";
  String empName = "";
  String uid = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          empName = doc['name'] ?? "Staff";
          companyCode = doc['companyCode'] ?? "";
        });
      }
    }
  }

  // 📅 તારીખ સિલેક્ટ કરવાનું ફંક્શન
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)), // કાલની તારીખ
      firstDate: DateTime.now(), // ગઈ કાલની રજા ના મંગાય
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && mounted) {
      setState(() => selectedDate = picked);
    }
  }

  // 🚀 રજાની રિકવેસ્ટ મોકલવાનું જાદુ
  void _submitLeave() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a date! 📅"), backgroundColor: Colors.orange));
      return;
    }
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please write a reason! ✍️"), backgroundColor: Colors.orange));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

      // ☁️ સીધી બોસના ડેટાબેઝમાં રિકવેસ્ટ જશે
      await FirebaseFirestore.instance.collection('leaves').add({
        'uid': uid,
        'empName': empName,
        'companyId': companyCode,
        'date': formattedDate,
        'reason': _reasonController.text.trim(),
        'status': 'Pending', // શરૂઆતમાં પેન્ડિંગ રહેશે
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isSubmitting = false;
        selectedDate = null;
        _reasonController.clear();
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Leave Request Sent to Boss! 🚀"), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Apply for Leave", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📝 રજા માંગવાનું ફોર્મ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("New Leave Request", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // Date Picker Button
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(selectedDate == null ? "Select Date" : DateFormat('dd MMM, yyyy').format(selectedDate!)),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), alignment: Alignment.centerLeft),
                  ),
                  const SizedBox(height: 15),
                  
                  // Reason TextField
                  TextField(
                    controller: _reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(hintText: "Reason for leave (e.g., Sick, Family function)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 15),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitLeave,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text("Submit Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("My Past Leaves", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // 📋 જૂની રજાઓનું લિસ્ટ (Live)
            Expanded(
              child: uid.isEmpty ? const Center(child: CircularProgressIndicator()) : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('leaves')
                    .where('uid', isEqualTo: uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No leave requests yet."));

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      String status = doc['status'];
                      Color statusColor = status == 'Approved' ? Colors.green : (status == 'Rejected' ? Colors.red : Colors.orange);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: statusColor.withOpacity(0.1), child: Icon(Icons.event_note, color: statusColor)),
                          title: Text(doc['date'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(doc['reason']),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}