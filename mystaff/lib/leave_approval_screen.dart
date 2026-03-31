import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  String companyCode = "";

  @override
  void initState() {
    super.initState();
    _loadCompanyCode();
  }

  void _loadCompanyCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      companyCode = prefs.getString('company_code') ?? "";
    });
  }

  // 🟢 રજા મંજૂર/નામંજૂર કરવાનું ફંક્શન
  void _updateLeaveStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('leaves').doc(docId).update({
      'status': newStatus,
    });
    
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Leave $newStatus!"), 
        backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Pending Leaves", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 1),
      body: companyCode.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            // 🚀 બોસ પોતાની કંપનીની બધી રજાઓ લાઈવ જોશે
            stream: FirebaseFirestore.instance.collection('leaves')
                .where('companyId', isEqualTo: companyCode)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No leave requests pending. 🎉"));

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  String status = doc['status'];
                  bool isPending = status == 'Pending';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(doc['empName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: isPending ? Colors.orange.shade50 : (status == 'Approved' ? Colors.green.shade50 : Colors.red.shade50), borderRadius: BorderRadius.circular(8)),
                                child: Text(status, style: TextStyle(color: isPending ? Colors.orange : (status == 'Approved' ? Colors.green : Colors.red), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(children: [const Icon(Icons.calendar_month, size: 16, color: Colors.grey), const SizedBox(width: 5), Text("Date: ${doc['date']}", style: const TextStyle(fontWeight: FontWeight.bold))]),
                          const SizedBox(height: 5),
                          Row(children: [const Icon(Icons.edit_document, size: 16, color: Colors.grey), const SizedBox(width: 5), Expanded(child: Text("Reason: ${doc['reason']}", style: const TextStyle(color: Colors.black87)))]),
                          
                          // જો રજા Pending હોય, તો જ Approve / Reject બટન દેખાશે
                          if (isPending) ...[
                            const SizedBox(height: 15),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateLeaveStatus(doc.id, 'Rejected'),
                                    icon: const Icon(Icons.close, color: Colors.red), label: const Text("Reject", style: TextStyle(color: Colors.red)),
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateLeaveStatus(doc.id, 'Approved'),
                                    icon: const Icon(Icons.check, color: Colors.white), label: const Text("Approve", style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              );
            },
        ),
    );
  }
}