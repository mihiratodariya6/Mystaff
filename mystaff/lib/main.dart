import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash_screen.dart'; // 👈 આપણો નવો મેમરી વાળો ગેટકીપર અહી આવી ગયો!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      // 👇 તમારી અસલી ચાવીઓ એમની એમ જ છે, સેજ પણ બદલી નથી:
      apiKey: "AIzaSyDavI6bIFISfuBLyYXs7IHhGus5J1UBB9U",
      authDomain: "mystaff-f7b12.firebaseapp.com",
      projectId: "mystaff-f7b12",
      storageBucket: "mystaff-f7b12.firebasestorage.app",
      messagingSenderId: "114587188132",
      appId: "1:114587188132:web:efea25f413201dd48e1f31",
    ),
  );

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
      // 🚀 અહી આપણે LoginScreen ની જગ્યાએ સીધું SplashScreen નાખી દીધું!
      home: const SplashScreen(), 
    );
  }
}