import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 Firebase Auth ઈમ્પોર્ટ
import 'role_screen.dart'; 

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final ConfirmationResult confirmationResult; // 👈 Login પરથી આવેલો ડેટા
  
  const OtpScreen({super.key, required this.phoneNumber, required this.confirmationResult});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyOTP() async {
    if (otpController.text.length == 6) { 
      setState(() => isLoading = true);
      
      try {
        // 🚀 અસલી OTP ફાયરબેઝ જોડે મેચ કરશે
        await widget.confirmationResult.confirm(otpController.text);
        
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful! 🎉"), backgroundColor: Colors.green));
          
          // OTP સાચો પડે એટલે Role Screen પર જશે
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleScreen()));
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP! Please try again ❌"), backgroundColor: Colors.red));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter 6 digits"), backgroundColor: Colors.orange));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter OTP 💬", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            Text("We have sent a verification code to ${widget.phoneNumber}", style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),
            
            const SizedBox(height: 40),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 15, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "000000",
                counterText: "", 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2)),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify & Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}