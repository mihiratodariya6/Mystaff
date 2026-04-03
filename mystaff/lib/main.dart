import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart'; 
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 Firebase ચાલુ કરો
  await Firebase.initializeApp();
  
  // 🔔 નોટિફિકેશન સર્વિસ ચાલુ કરો
  await NotificationService.initialize(); 

  runApp(const MyStaffApp());
}

class MyStaffApp extends StatelessWidget {
  const MyStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyStaff',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0),
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}