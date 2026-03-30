import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'otp_screen.dart'; // OTP screen link chhe

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String fullPhoneNumber = ''; 
  bool isLoading = false; 

  Future<void> sendOTP() async {
    if (fullPhoneNumber.isEmpty || fullPhoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sacho Mobile Number nakho!")),
      );
      return;
    }

    setState(() { isLoading = true; });
    await Future.delayed(const Duration(seconds: 2)); // 2 sec dummy loading
    setState(() { isLoading = false; });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(
          verificationId: "dummy_123",
          phoneNumber: fullPhoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 16),
              const Text('MyStaff', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
              const SizedBox(height: 40),
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2), borderRadius: BorderRadius.circular(12)),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) { fullPhoneNumber = phone.completeNumber; },
              ),
              const SizedBox(height: 12),
              const Text('We will send a 6-digit OTP for verification', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendOTP, 
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Get OTP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [Icon(Icons.lock_outline, size: 14, color: Colors.grey), SizedBox(width: 4), Text('Secure Login', style: TextStyle(color: Colors.grey, fontSize: 12))],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}