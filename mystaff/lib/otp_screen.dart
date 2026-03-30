import 'package:flutter/material.dart';
import 'role_screen.dart'; // 👈 Navi Role Screen ne link kari didhi chhe

class OtpScreen extends StatefulWidget {
  final String verificationId; 
  final String phoneNumber; 

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String currentText = "";
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (currentText.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pura 6 aakda no OTP nakho!"))
      );
      return;
    }

    setState(() { isLoading = true; });
    
    // ⏳ 2 Second nu dummy verify (UI testing mate)
    await Future.delayed(const Duration(seconds: 2)); 
    
    setState(() { isLoading = false; });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login Successful! 🎉"))
    );
    
    // 👇 Aahiya thi direct Role Screen par jase (ane pacha na aavi shakay e rite)
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleScreen()),
      (route) => false, // Pacha OTP screen par javano rasto bandh
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context)
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Verify OTP',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey)
              ),
              const SizedBox(height: 40),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    letterSpacing: 20, // 6 Box jevu look aapse
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0)
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: Colors.blue.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none
                    ),
                  ),
                  onChanged: (value) {
                    setState(() { currentText = value; });
                  },
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify OTP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Didn't receive code? Resend",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}