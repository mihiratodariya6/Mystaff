import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart'; 
import 'splash_screen.dart';

// 👇 આ નવી લાઈન આપણે ઉમેરી (ફાયરબેઝનું સરનામું ઈમ્પોર્ટ કરવા)
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 🔥 ફાયરબેઝને સાચું સરનામું (options) આપીને ચાલુ કરો
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // 👈 આ નાખવું સૌથી જરૂરી હતું!
    );
    
    await NotificationService.initialize(); 

    // જો બધું બરાબર હશે તો એપ ચાલુ થશે
    runApp(const MyStaffApp());
  } catch (e) {
    // 🚨 કોઈ એરર આવશે તો લાલ અક્ષરમાં બતાવશે
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "અરેરે! કંઈક ભૂલ છે:\n\n$e", 
              style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
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