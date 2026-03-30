import 'package:flutter/material.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  // 👥 Dummy pending requests (આ ડેટા ભવિષ્યમાં Firebase માંથી આવશે)
  List<Map<String, String>> pendingLeaves = [
    {"name": "Rahul Sharma", "date": "March 30, 2026", "type": "Sick Leave", "reason": "Fever and cold since morning."},
    {"name": "Priya Patel", "date": "April 02, 2026", "type": "Casual Leave", "reason": "Going to hometown for a family function."},
  ];

  void _handleLeave(int index, bool isApproved) {
    String action = isApproved ? "Approved" : "Rejected";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Leave $action for ${pendingLeaves[index]['name']}"), backgroundColor: isApproved ? Colors.green : Colors.red));
    setState(() {
      pendingLeaves.removeAt(index); // લિસ્ટમાંથી કાઢી નાખો
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Pending Leaves", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: pendingLeaves.isEmpty 
        ? const Center(child: Text("No pending leave requests! 🎉", style: TextStyle(fontSize: 18, color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: pendingLeaves.length,
            itemBuilder: (context, index) {
              final leave = pendingLeaves[index];
              return Card(
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(leave['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)), child: Text(leave['type']!, style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(leave['date']!, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))]),
                      const SizedBox(height: 10),
                      Text('"${leave['reason']!}"', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 15),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(onPressed: () => _handleLeave(index, false), icon: const Icon(Icons.close, color: Colors.red), label: const Text("Reject", style: TextStyle(color: Colors.red))),
                          TextButton.icon(onPressed: () => _handleLeave(index, true), icon: const Icon(Icons.check, color: Colors.green), label: const Text("Approve", style: TextStyle(color: Colors.green))),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}