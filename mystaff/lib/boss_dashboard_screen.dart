import 'package:flutter/material.dart';
import 'staff_details_screen.dart';
import 'leave_approval_screen.dart'; // 👈 નવી રજા મંજૂર કરવાની સ્ક્રીન

class BossDashboardScreen extends StatefulWidget {
  final String companyName;
  final String companyId;

  const BossDashboardScreen({
    super.key, 
    this.companyName = "Mihir Enterprises", 
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

  // --- 🏠 MAIN DASHBOARD ---
  Widget _buildMainDashboard() {
    final List<Map<String, String>> staffList = [
      {"name": "Rahul Sharma", "role": "General Manager", "status": "Present", "present": "22", "late": "2", "absent": "1"},
      {"name": "Priya Patel", "role": "Accountant", "status": "Late", "present": "20", "late": "4", "absent": "1"},
      {"name": "Amit Shah", "role": "Sales Executive", "status": "Absent", "present": "18", "late": "1", "absent": "6"},
      {"name": "Sneha Gupta", "role": "HR Admin", "status": "Present", "present": "24", "late": "0", "absent": "1"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Good Afternoon, Boss! 👋", style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(widget.companyName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(radius: 25, backgroundColor: Color(0xFF1565C0), child: Icon(Icons.person, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildStatCard("Present", "12", Colors.green),
              _buildStatCard("Absent", "03", Colors.red),
              _buildStatCard("Late", "02", Colors.orange),
            ],
          ),
          const SizedBox(height: 25),
          _buildInviteCard(),
          const SizedBox(height: 30),
          const Text("Staff Members", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: staffList.length,
            itemBuilder: (context, index) {
              return _buildStaffItem(staffList[index]);
            },
          ),
        ],
      ),
    );
  }

  // --- 📅 ATTENDANCE PAGE ---
  Widget _buildAttendancePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Detailed Attendance", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: [
                _attendanceTile("Rahul Sharma", "Check-in: 09:15 AM", "On Time", Colors.green),
                _attendanceTile("Priya Patel", "Check-in: 10:30 AM", "Late", Colors.orange),
                _attendanceTile("Amit Shah", "---", "Absent", Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 📄 REPORTS PAGE ---
  Widget _buildReportsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Company Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _reportItem("Monthly Attendance Summary", Icons.analytics, Colors.blue),
          _reportItem("Salary & Overtime Report", Icons.payments, Colors.green),
          _reportItem("Late Comers Analysis", Icons.timer, Colors.orange),
          
          // 🚀 અહી Pending Leaves નું બટન લિંક થઈ ગયું છે 
          _reportItem(
            "Pending Leave Requests", 
            Icons.event_busy_outlined, 
            Colors.red,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApprovalScreen()));
            }
          ),
        ],
      ),
    );
  }

  // --- ⚙️ SETTINGS PAGE ---
  Widget _buildSettingsPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _settingTile("Edit Company Profile", Icons.business),
        _settingTile("Manage Admin Access", Icons.security),
        _settingTile("Logout", Icons.logout, color: Colors.red),
      ],
    );
  }

  // --- UI HELPERS ---
  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
      ),
    );
  }

  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1976D2)]), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Invite Your Staff", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Share Code: MS-RT913", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue), child: const Text("Share")),
        ],
      ),
    );
  }

  Widget _buildStaffItem(Map<String, String> staff) {
    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => StaffDetailsScreen(staffData: staff))),
      leading: CircleAvatar(child: Text(staff['name']![0])),
      title: Text(staff['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(staff['role']!),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _attendanceTile(String name, String time, String status, Color color) {
    return Card(
      child: ListTile(title: Text(name), subtitle: Text(time), trailing: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
    );
  }

  // 👈 અહી મેં `onTap` એડ કર્યું છે
  Widget _reportItem(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color), 
      title: Text(title), 
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap, // 👈 Click Event
    );
  }

  Widget _settingTile(String title, IconData icon, {Color color = Colors.black}) {
    return ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)));
  }
}