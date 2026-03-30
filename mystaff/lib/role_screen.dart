import 'package:flutter/material.dart';
import 'boss_setup_screen.dart';
import 'employee_dashboard_screen.dart'; // 👈 Navu Dashboard link karyu

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // 🎨 Welcome Title
              const Text(
                'Welcome to MyStaff! 🎉',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF0D47A1)
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select your role to continue.',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 👑 1. Boss Card
              _buildRoleCard(
                context,
                title: 'I am a Boss / Owner',
                subtitle: 'I want to manage my company, staff, and attendance reports.',
                icon: Icons.business_center,
                color: const Color(0xFF1565C0),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BossSetupScreen(userPhone: "+91 99242 47523"),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),

              // 👨‍💻 2. Employee Card (Sidhu Dashboard par)
              _buildRoleCard(
                context,
                title: 'I am an Employee',
                subtitle: 'I want to mark my daily attendance and view my reports.',
                icon: Icons.person_pin_circle_outlined,
                color: Colors.green,
                onTap: () {
                  // 🚀 NAVIGATE TO EMPLOYEE DASHBOARD
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeDashboardScreen(),
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // 🛡️ Security Badge
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'End-to-End Encrypted & Secure',
                      style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Role Cards
  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05), 
              blurRadius: 15, 
              offset: const Offset(0, 8)
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle, 
                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }
}