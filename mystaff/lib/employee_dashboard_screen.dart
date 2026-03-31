import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:geolocator/geolocator.dart'; // 🚀 લોકેશન એન્જિન

import 'login_screen.dart'; 
import 'chat_conversation_screen.dart'; 
import 'edit_profile_screen.dart';       
import 'employee_settings_screen.dart';   
import 'leave_application_screen.dart'; 
import 'my_documents_screen.dart';       
import 'salary_slips_screen.dart';       

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  String empName = "Loading...";
  String companyCode = "";
  String empRole = "Staff";
  String empIdDisplay = "EMP-000";

  String? currentDocId; 
  bool isCheckedIn = false;
  String checkInTime = "--:--";
  String checkOutTime = "--:--";

  // 📍 ટ્રેકિંગ માટેના નવા વેરીએબલ
  bool isLocating = false; 
  double officeLat = 21.1702; 
  double officeLng = 72.8311; 
  bool isOfficeLocationSet = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          empName = doc['name'] ?? "Employee";
          companyCode = doc['companyCode'] ?? "";
          empRole = doc['role'] ?? "Staff";
          empIdDisplay = doc['empId'] ?? "EMP-000";
        });
      }
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

  // 🚀 અસલી સ્માર્ટ ટ્રેકિંગ એન્જિન (Geofencing vs Remote)
  void _verifyLocationAndPunch() async {
    setState(() => isLocating = true);

    try {
      // ૧. લોકેશન ચાલુ છે?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorDialog("Location Disabled", "Please turn on your GPS to mark attendance.");
        setState(() => isLocating = false);
        return;
      }

      // ૨. પરમિશન છે?
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorDialog("Permission Denied", "App needs location permission.");
          setState(() => isLocating = false);
          return;
        }
      }

      // ૩. લાઈવ લોકેશન કાઢો
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // ૪. બોસની પરમિશન ચેક કરો (ડેટાબેઝમાંથી)
      User? user = FirebaseAuth.instance.currentUser;
      bool isRemoteAllowed = false;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          isRemoteAllowed = data['isRemoteAllowed'] ?? false;
        }
      }

      // પહેલીવાર દબાવો ત્યારે જ્યાં બેઠા છો એને જ ઓફિસ માની લેશે (ટેસ્ટિંગ માટે)
      if (!isOfficeLocationSet) {
        officeLat = position.latitude; officeLng = position.longitude;
        isOfficeLocationSet = true;
      }

      // ૫. 🧠 સ્માર્ટ ડિસિઝન
      if (isRemoteAllowed) {
        // 🛵 ફિલ્ડ સ્ટાફ (50m નો નિયમ નહિ લાગે)
        _handlePunch();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remote Check-In ✅ (Location Sent to Boss)"), backgroundColor: Colors.blue));
      } else {
        // 🏢 ઓફિસ સ્ટાફ (50m નો કડક નિયમ)
        double distanceInMeters = Geolocator.distanceBetween(officeLat, officeLng, position.latitude, position.longitude);
        
        if (distanceInMeters > 50) {
          _showProUpgradeDialog(distanceInMeters.toInt());
        } else {
          _handlePunch();
        }
      }
    } catch (e) {
      _showErrorDialog("GPS Error", "Failed to get location: $e");
    } finally {
      setState(() => isLocating = false);
    }
  }

  void _showProUpgradeDialog(int distance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(children: [Icon(Icons.location_off, color: Colors.red, size: 50), SizedBox(height: 10), Text("Out of Range!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
        content: Text("You are $distance meters away from the office.\n\nStrict GPS Geofencing is enabled. Please reach the office to Check-In or ask Boss for Remote Permission.", textAlign: TextAlign.center),
        actions: [SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Okay", style: TextStyle(color: Colors.white))))],
      ),
    );
  }

  void _showErrorDialog(String title, String msg) {
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(title), content: Text(msg), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
  }

  // જૂનો નોર્મલ હાજરી વાળો કોડ 
  void _handlePunch() async {
    if (companyCode.isEmpty) return; 

    String currentTime = DateFormat('hh:mm a').format(DateTime.now());
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (!isCheckedIn) {
      setState(() { isCheckedIn = true; checkInTime = currentTime; });
      DocumentReference docRef = await FirebaseFirestore.instance.collection('attendance').add({
        'empName': empName, 'companyId': companyCode, 'date': todayDate, 'checkIn': currentTime, 'checkOut': '--:--', 'status': 'Present', 'timestamp': FieldValue.serverTimestamp(),
      });
      currentDocId = docRef.id; 
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checked In Successfully! ✅"), backgroundColor: Colors.green));
    } else {
      setState(() { isCheckedIn = false; checkOutTime = currentTime; });
      if (currentDocId != null) {
        await FirebaseFirestore.instance.collection('attendance').doc(currentDocId).update({'checkOut': currentTime});
      }
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checked Out Successfully! 🛑"), backgroundColor: Colors.orange));
    }
  }

  // 👥 DUMMY DATA FOR TEAM
  List<Map<String, dynamic>> colleagues = [
    {"name": "Rahul Sharma", "role": "General Manager", "status": "following", "image": "R", "stars": 4.8},
    {"name": "Priya Patel", "role": "Accountant", "status": "none", "image": "P", "stars": 4.5},
    {"name": "Sneha Gupta", "role": "HR Admin", "status": "none", "image": "S", "stars": 4.2},
  ];

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildHome();       
      case 1: return _buildHistory();    
      case 2: return _buildTeam();       
      case 3: return _buildChatList();   
      case 4: return _buildProfile();    
      default: return _buildHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _getBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Team"), 
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildLiveClock(),
          const SizedBox(height: 40),
          _buildAttendanceButton(), // 👈 અહી ફેરફાર છે
          const SizedBox(height: 40),
          Row(
            children: [
              _infoCard("Check In", checkInTime, Icons.login, Colors.green),
              const SizedBox(width: 15),
              _infoCard("Check Out", checkOutTime, Icons.logout, Colors.orange),
            ],
          ),
          const Spacer(),
          _buildMonthlySummary(),
        ],
      ),
    );
  }

  // 🚀 જીઓ-ફેન્સિંગ વાળું નવું બટન 
  Widget _buildAttendanceButton() {
    return GestureDetector(
      onTap: isLocating ? null : (isCheckedIn ? _handlePunch : _verifyLocationAndPunch),
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          color: isCheckedIn ? Colors.red.shade50 : Colors.green.shade50, 
          border: Border.all(color: isCheckedIn ? Colors.red : Colors.green, width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            isLocating 
              ? const CircularProgressIndicator() 
              : Icon(isCheckedIn ? Icons.front_hand : Icons.touch_app, size: 40, color: isCheckedIn ? Colors.red : Colors.green),
            const SizedBox(height: 10),
            Text(isLocating ? "Verifying..." : (isCheckedIn ? "CHECK OUT" : "CHECK IN"), style: TextStyle(fontWeight: FontWeight.bold, color: isCheckedIn ? Colors.red : Colors.green)),
          ]
        ),
      ),
    );
  }

  Widget _buildHistory() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Attendance History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1), lastDay: DateTime.utc(2030, 12, 31), focusedDay: DateTime.now(),
            calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam() {
    return DefaultTabController(length: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(left: 20, top: 20, bottom: 10), child: Text("My Team", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), const TabBar(labelColor: Color(0xFF1565C0), unselectedLabelColor: Colors.grey, indicatorColor: Color(0xFF1565C0), indicatorWeight: 3, tabs: [Tab(icon: Icon(Icons.people_alt_outlined), text: "Network"), Tab(icon: Icon(Icons.emoji_events_outlined), text: "Leaderboard")]), Expanded(child: TabBarView(children: [_buildNetwork(), _buildLeaderboard()]))]));
  }
  Widget _buildNetwork() { return ListView.builder(padding: const EdgeInsets.only(top: 10), itemCount: colleagues.length, itemBuilder: (context, index) { final coll = colleagues[index]; return ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(coll['image'], style: const TextStyle(color: Color(0xFF1565C0)))), title: Text(coll['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(coll['role']), trailing: _buildFollowButton(index, coll['status'])); }); }
  Widget _buildLeaderboard() { List<Map<String, dynamic>> sortedList = List.from(colleagues); sortedList.sort((a, b) => b['stars'].compareTo(a['stars'])); return ListView.builder(padding: const EdgeInsets.all(15), itemCount: sortedList.length, itemBuilder: (context, index) { final emp = sortedList[index]; bool isTop3 = index < 3; Color medalColor = index == 0 ? Colors.amber : (index == 1 ? Colors.grey.shade400 : (index == 2 ? Colors.brown.shade300 : Colors.transparent)); return Card(elevation: isTop3 ? 2 : 0, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isTop3 ? medalColor : Colors.grey.shade200, width: isTop3 ? 2 : 1)), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), leading: Stack(alignment: Alignment.topRight, children: [CircleAvatar(radius: 25, backgroundColor: isTop3 ? medalColor.withOpacity(0.1) : Colors.blue.shade50, child: Text(emp['image'], style: TextStyle(color: isTop3 ? medalColor : const Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 18))), if (isTop3) Icon(Icons.stars, color: medalColor, size: 20)]), title: Text(emp['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(emp['role'], style: const TextStyle(fontSize: 12)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(emp['stars'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(width: 5), const Icon(Icons.star, color: Colors.amber, size: 22)]))); }); }
  Widget _buildFollowButton(int index, String status) { bool isFollowing = status == "following"; return Container(width: 100, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: isFollowing ? Colors.grey.shade200 : const Color(0xFF1565C0), borderRadius: BorderRadius.circular(8)), child: Text(isFollowing ? "Following" : "Follow", style: TextStyle(color: isFollowing ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold, fontSize: 13))); }
  Widget _buildChatList() { List<Map<String, dynamic>> activeChats = colleagues.where((c) => c['status'] == "following").toList(); return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.all(20), child: Text("Messages", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), ListTile(leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.business_center, color: Colors.white, size: 20)), title: const Text("Boss / Admin", style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text("Tap to chat..."), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatConversationScreen(name: "Boss / Admin")));}), const Divider(), Expanded(child: ListView.builder(itemCount: activeChats.length, itemBuilder: (context, index) { return ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(activeChats[index]['image'], style: const TextStyle(color: Color(0xFF1565C0)))), title: Text(activeChats[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text("Active now..."), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ChatConversationScreen(name: activeChats[index]['name'])));}); }))]); }
  Widget _buildProfile() { return ListView(children: [Padding(padding: const EdgeInsets.all(20), child: Row(children: [const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: Colors.grey)), const SizedBox(width: 20), Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_profileStat("22", "Days\nPresent"), _profileStat("4.9", "Current\nRating"), _profileStat("45", "Following")]))])), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(empName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("$empRole 🚀", style: const TextStyle(fontSize: 14)), const SizedBox(height: 5), Text("ID: $empIdDisplay | Co. Code: $companyCode", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))])), const SizedBox(height: 20), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [Expanded(child: _profileBtn("Edit Profile", Icons.edit, () {Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));})), const SizedBox(width: 10), Expanded(child: _profileBtn("Settings", Icons.settings, () {Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeSettingsScreen()));}))])), const SizedBox(height: 30), const Divider(), _profileTile("My Documents", Icons.file_copy_outlined, onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDocumentsScreen()));}), _profileTile("Apply for Leave", Icons.event_note_outlined, onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApplicationScreen()));}), _profileTile("Salary Slips", Icons.receipt_long_outlined, onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const SalarySlipsScreen()));}), _profileTile("Logout", Icons.logout, color: Colors.red, onTap: _showLogoutDialog)]); }
  Widget _profileStat(String val, String label) { return Column(children: [Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))]); }
  Widget _profileBtn(String text, IconData icon, VoidCallback onTap) { return ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, size: 16, color: Colors.black), label: Text(text, style: const TextStyle(color: Colors.black, fontSize: 13)), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0)); }
  Widget _buildLiveClock() { return Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)), child: Column(children: [Text(DateFormat('EEEE, MMM dd').format(DateTime.now()), style: const TextStyle(color: Colors.blueGrey)), const SizedBox(height: 5), Text(DateFormat('hh:mm:ss a').format(DateTime.now()), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)))])); }
  Widget _infoCard(String label, String time, IconData icon, Color color) { return Expanded(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]), Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]))); }
  Widget _buildMonthlySummary() { return Column(children: [const Align(alignment: Alignment.centerLeft, child: Text("Monthly Overview", style: TextStyle(fontWeight: FontWeight.bold))), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_miniStat("24", "Days"), _miniStat("22", "Present"), _miniStat("02", "Absent")]), const SizedBox(height: 20)]); }
  Widget _miniStat(String val, String label) { return Column(children: [Text(val, style: const TextStyle(fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))]); }
  Widget _profileTile(String title, IconData icon, {Color color = Colors.black, VoidCallback? onTap}) { return ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)), trailing: const Icon(Icons.chevron_right), onTap: onTap); }
}