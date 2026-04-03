import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:intl/intl.dart'; 
import 'notification_service.dart';

import 'staff_details_screen.dart';
import 'leave_approval_screen.dart'; 
import 'company_reports_screens.dart'; 
import 'subscription_screen.dart';    
import 'login_screen.dart'; 

class BossDashboardScreen extends StatefulWidget {
  final String companyName;
  final String companyId;

  const BossDashboardScreen({
    super.key, 
    this.companyName = "My Company", 
    this.companyId = "MS-RT913"
  });

  @override
  State<BossDashboardScreen> createState() => _BossDashboardScreenState();
}

class _BossDashboardScreenState extends State<BossDashboardScreen> {
  int _selectedIndex = 0;

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildMainDashboard();
      case 1: return _buildAttendancePage();
      case 2: return _buildReportsPage();
      case 3: return _buildSettingsPage(); 
      default: return _buildMainDashboard();
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('company_code');

    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _logout(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: "Reports"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildMainDashboard() {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('employees').where('companyCode', isEqualTo: widget.companyId).snapshots(),
      builder: (context, empSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('attendance').where('companyId', isEqualTo: widget.companyId).where('date', isEqualTo: todayDate).snapshots(),
          builder: (context, attSnapshot) {

            int totalEmployees = empSnapshot.hasData ? empSnapshot.data!.docs.length : 0;
            int presentCount = attSnapshot.hasData ? attSnapshot.data!.docs.length : 0;
            int absentCount = totalEmployees > 0 ? (totalEmployees - presentCount) : 0;

            List<Widget> staffWidgets = [];
            if (empSnapshot.hasData && empSnapshot.data!.docs.isNotEmpty) {
              for (var empDoc in empSnapshot.data!.docs) {
                String empName = empDoc['name'] ?? "Staff";
                String empRole = empDoc['role'] ?? "Employee";
                String empUid = empDoc.id; 

                bool isPresent = false;
                if (attSnapshot.hasData) {
                  for (var attDoc in attSnapshot.data!.docs) {
                    if (attDoc['empName'] == empName) { isPresent = true; break; }
                  }
                }

                staffWidgets.add(_buildStaffItem({
                  "uid": empUid, 
                  "name": empName,
                  "role": empRole,
                  "status": isPresent ? "Present" : "Absent", 
                  'stars': empDoc['stars'] ?? "0.0"
                }));
              }
            } else {
              staffWidgets.add(const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text("No staff joined yet.", style: TextStyle(color: Colors.grey)))));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Good Afternoon, Boss! 👋", style: TextStyle(fontSize: 14, color: Colors.grey)), Text(widget.companyName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                      const CircleAvatar(radius: 25, backgroundColor: Color(0xFF1565C0), child: Icon(Icons.person, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(children: [_buildStatCard("Total Staff", totalEmployees.toString(), Colors.blue), _buildStatCard("Present", presentCount.toString(), Colors.green), _buildStatCard("Absent", absentCount.toString(), Colors.red)]),
                  const SizedBox(height: 25),
                  _buildInviteCard(),
                  const SizedBox(height: 30),
                  const Text("Staff Members (Live)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ...staffWidgets,
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildAttendancePage() {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Live Attendance (Today)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('attendance').where('companyId', isEqualTo: widget.companyId).where('date', isEqualTo: todayDate).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Nobody has checked in yet."));
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    String empName = doc['empName'] ?? "Staff";
                    String checkIn = doc['checkIn'] ?? "--:--";
                    String checkOut = doc['checkOut'] ?? "--:--";
                    bool isOut = checkOut != '--:--';
                    return _attendanceTile(empName, "In: $checkIn  |  Out: $checkOut", isOut ? "Checked Out" : "Present", isOut ? Colors.orange : Colors.green);
                  },
                );
              }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReportsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Company Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _reportItem("Monthly Attendance Summary", Icons.analytics, Colors.blue, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyAttendanceReport()));
          }),
          _reportItem("Salary & Overtime Report", Icons.payments, Colors.green, onTap: () {}),
          _reportItem("Late Comers Analysis", Icons.timer, Colors.orange, onTap: () {}),
          _reportItem("Pending Leave Requests", Icons.event_busy_outlined, Colors.red, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApprovalScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade200, Colors.amber.shade400]), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.workspace_premium, color: Colors.black87),
            title: const Text("Upgrade to PRO Plan", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            trailing: const Icon(Icons.chevron_right, color: Colors.black87),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionScreen(companyCode: widget.companyId)));
            },
          ),
        ),
        _settingTile("Edit Company Profile", Icons.business, onTap: () {}),
        _settingTile("Manage Admin Access", Icons.security, onTap: () {}),
        _settingTile("Logout", Icons.logout, color: Colors.red, onTap: _showLogoutDialog),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) { return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))]))); }
  Widget _buildInviteCard() { return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(15)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Invite Your Staff", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), Text("Share Code: ${widget.companyId}", style: const TextStyle(color: Colors.white70, fontSize: 12))])), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue), child: const Text("Share"))])); }
  Widget _buildStaffItem(Map<String, String> staff) {
    Color statusColor = staff['status'] == "Present" ? Colors.green : (staff['status'] == "Late" ? Colors.orange : Colors.red);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailsScreen(staffData: staff, staffUid: staff['uid'] ?? ""))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(staff['name']![0])),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(staff['name']!, style: const TextStyle(fontWeight: FontWeight.bold)), Text(staff['role']!, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            Row(children: [Text(staff['stars'] ?? "0.0", style: const TextStyle(fontWeight: FontWeight.bold)), const Icon(Icons.star, color: Colors.amber, size: 16)]),
            const SizedBox(width: 10),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(staff['status']!, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
  Widget _attendanceTile(String name, String time, String status, Color color) { return Card(child: ListTile(title: Text(name), subtitle: Text(time), trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)))); }
  Widget _reportItem(String title, IconData icon, Color color, {VoidCallback? onTap}) { return ListTile(leading: Icon(icon, color: color), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap); }
  Widget _settingTile(String title, IconData icon, {Color color = Colors.black, VoidCallback? onTap}) { return ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)), onTap: onTap); }
}