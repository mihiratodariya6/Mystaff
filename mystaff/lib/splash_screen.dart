import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'role_screen.dart';
import 'boss_dashboard_screen.dart';
import 'employee_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // એપ ખુલતા જ ચેકિંગ ચાલુ
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // 2 સેકન્ડ મસ્ત લોગો બતાવવા

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 1. જો લોગીન જ ના કર્યું હોય તો સીધા Login પેજ પર 
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      // 2. જો લોગીન હોય, તો મેમરીમાંથી ચેક કરો કે એ બોસ છે કે એમ્પ્લોઈ?
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userRole = prefs.getString('user_role');

      if (mounted) {
        if (userRole == 'boss') {
          // સીધા બોસના ડેશબોર્ડ પર 🚀
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BossDashboardScreen()));
        } else if (userRole == 'employee') {
          // સીધા એમ્પ્લોઈના ડેશબોર્ડ પર 🚀
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()));
        } else {
          // જો લોગીન છે પણ રોલ નક્કી નથી કર્યો, તો Role પેજ પર
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleScreen()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_center, size: 100, color: Color(0xFF1565C0))),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFF1565C0)), // ગોળ ફરતું લોડિંગ
          ],
        ),
      ),
    );
  }
}