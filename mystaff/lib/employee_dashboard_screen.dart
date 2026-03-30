import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';

// 🔗 બધી નવી ફાઈલો અહી ઈમ્પોર્ટ કરેલી છે
import 'chat_conversation_screen.dart'; 
import 'edit_profile_screen.dart';       
import 'employee_settings_screen.dart';   
import 'leave_application_screen.dart'; 
import 'my_documents_screen.dart';       // 👈 નવું
import 'salary_slips_screen.dart';       // 👈 નવું

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _selectedIndex = 0;

  // 👥 DUMMY DATA FOR NETWORK (Insta Style)
  List<Map<String, dynamic>> colleagues = [
    {"name": "Rahul Sharma", "role": "General Manager", "status": "following", "image": "R"},
    {"name": "Priya Patel", "role": "Accountant", "status": "none", "image": "P"},
    {"name": "Amit Shah", "role": "Sales Exec", "status": "requested", "image": "A"},
    {"name": "Sneha Gupta", "role": "HR Admin", "status": "none", "image": "S"},
  ];

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildHome();       
      case 1: return _buildHistory();    
      case 2: return _buildNetwork();    
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
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: "Network"),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  // --- 🏠 1. HOME: ATTENDANCE ---
  bool isCheckedIn = false;
  String checkInTime = "--:--";
  String checkOutTime = "--:--";

  Widget _buildHome() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          _buildLiveClock(),
          const SizedBox(height: 40),
          _buildAttendanceButton(),
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

  // --- 📅 2. HISTORY ---
  Widget _buildHistory() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Attendance History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            calendarStyle: const CalendarStyle(todayDecoration: BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle)),
          ),
        ],
      ),
    );
  }

  // --- 👥 3. NETWORK ---
  Widget _buildNetwork() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Office Network", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: colleagues.length,
            itemBuilder: (context, index) {
              final coll = colleagues[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(coll['image'], style: const TextStyle(color: Color(0xFF1565C0))),
                ),
                title: Text(coll['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(coll['role']),
                trailing: _buildFollowButton(index, coll['status']),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton(int index, String status) {
    bool isFollowing = status == "following";
    bool isRequested = status == "requested";

    return Container(
      width: 100,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isFollowing || isRequested ? Colors.grey.shade200 : const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isFollowing ? "Following" : (isRequested ? "Requested" : "Follow"),
        style: TextStyle(
          color: isFollowing || isRequested ? Colors.black87 : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  // --- 💬 4. CHAT LIST ---
  Widget _buildChatList() {
    List<Map<String, dynamic>> activeChats = colleagues.where((c) => c['status'] == "following").toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Messages", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.business_center, color: Colors.white, size: 20)),
          title: const Text("Boss / Admin", style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text("Tap to chat..."),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatConversationScreen(name: "Boss / Admin")));
          },
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: activeChats.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Text(activeChats[index]['image'], style: const TextStyle(color: Color(0xFF1565C0))),
                ),
                title: Text(activeChats[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Active now..."),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatConversationScreen(name: activeChats[index]['name'])));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 👤 5. PROFILE ---
  Widget _buildProfile() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: Colors.grey)),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileStat("22", "Days\nPresent"),
                    _profileStat("128", "Followers"),
                    _profileStat("45", "Following"),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mihir Atodariya", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Flutter Developer 🚀"),
              Text("ID: EMP-007 | Surat, India", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _profileBtn("Edit Profile", Icons.edit, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _profileBtn("Settings", Icons.settings, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeeSettingsScreen()));
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        const Divider(),

        // 🚀 અહી બધા નવા ઓપ્શન લિંક થઈ ગયા છે
        _profileTile("My Documents", Icons.file_copy_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyDocumentsScreen()));
        }),
        
        _profileTile("Apply for Leave", Icons.event_note_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApplicationScreen()));
        }),
        
        _profileTile("Salary Slips", Icons.receipt_long_outlined, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SalarySlipsScreen()));
        }),

        _profileTile("Logout", Icons.logout, color: Colors.red, onTap: () {
          // ભવિષ્યમાં અહી લોગઆઉટ નું લોજીક આવશે
        }),
      ],
    );
  }

  Widget _profileStat(String val, String label) {
    return Column(children: [Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))]);
  }

  Widget _profileBtn(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black, fontSize: 13)),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0),
    );
  }

  // --- UI HELPERS ---
  Widget _buildLiveClock() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Text(DateFormat('EEEE, MMM dd').format(DateTime.now()), style: const TextStyle(color: Colors.blueGrey)),
        const SizedBox(height: 5),
        Text(DateFormat('hh:mm:ss a').format(DateTime.now()), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
      ]),
    );
  }

  Widget _buildAttendanceButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCheckedIn = !isCheckedIn;
          if (isCheckedIn) checkInTime = DateFormat('hh:mm a').format(DateTime.now()); 
          else checkOutTime = DateFormat('hh:mm a').format(DateTime.now());
        });
      },
      child: Container(
        width: 180, height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle, color: isCheckedIn ? Colors.red.shade50 : Colors.green.shade50,
          border: Border.all(color: isCheckedIn ? Colors.red : Colors.green, width: 3),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.touch_app, size: 40, color: isCheckedIn ? Colors.red : Colors.green),
          Text(isCheckedIn ? "CHECK OUT" : "CHECK IN", style: TextStyle(fontWeight: FontWeight.bold, color: isCheckedIn ? Colors.red : Colors.green)),
        ]),
      ),
    );
  }

  Widget _infoCard(String label, String time, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Column(children: [
      const Align(alignment: Alignment.centerLeft, child: Text("Monthly Overview", style: TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _miniStat("24", "Days"), _miniStat("22", "Present"), _miniStat("02", "Absent"),
      ]),
      const SizedBox(height: 20),
    ]);
  }

  Widget _miniStat(String val, String label) {
    return Column(children: [Text(val, style: const TextStyle(fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11))]);
  }

  // 👈 અહી onTap પેરામીટર એડ કરેલો છે, જેથી બટન ક્લિક થાય
  Widget _profileTile(String title, IconData icon, {Color color = Colors.black, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color), 
      title: Text(title, style: TextStyle(color: color)), 
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap, 
    );
  }
}