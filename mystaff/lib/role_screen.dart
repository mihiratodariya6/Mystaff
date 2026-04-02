import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 મેમરીમાં સેવ કરવા માટે

// 🔗 બને નવા સેટઅપ પેજ અહી ઈમ્પોર્ટ કર્યા છે
import 'boss_setup_screen.dart'; 
import 'employee_details_screen.dart'; 

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Who are you?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Select your role to continue.", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 50),
              
              // 👑 BOSS BUTTON
              _roleCard(
                context, 
                "Boss / Admin", 
                "Manage your staff, attendance & reports.", 
                Icons.admin_panel_settings, 
                Colors.orange, 
                () async {
                  // 🚀 ૧. ફોનની મેમરીમાં કાયમ માટે સેવ કરો કે આ બોસ છે
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_role', 'boss');

                  // 🚀 ૨. ડેશબોર્ડની જગ્યાએ પહેલા Boss Setup Screen ખુલશે
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BossSetupScreen()));
                  }
                }
              ),
              
              const SizedBox(height: 20),
              
              // 👨‍💼 EMPLOYEE BUTTON
              _roleCard(
                context, 
                "Employee / Staff", 
                "Mark attendance, apply for leave & view slips.", 
                Icons.badge, 
                const Color(0xFF1565C0), 
                () async {
                  // 🚀 ૧. ફોનની મેમરીમાં કાયમ માટે સેવ કરો કે આ એમ્પ્લોઈ છે
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_role', 'employee');

                  // 🚀 ૨. ડેશબોર્ડની જગ્યાએ પહેલા Employee Details ફોર્મ ખુલશે
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDetailsScreen()));
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 મસ્ત UI માટેનું કાર્ડ ફંક્શન
  Widget _roleCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: color.withOpacity(0.3), width: 2)
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: color, child: Icon(icon, color: Colors.white, size: 30)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}