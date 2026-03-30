import 'package:flutter/material.dart';
import 'login_screen.dart'; // Aapni login screen nu link

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        primaryColor: const Color(0xFF1565C0), // Premium Blue
        scaffoldBackgroundColor: Colors.white,
      ),
      home: LoginScreen(), // App khulta j Login Screen aavse
    );
  }
}