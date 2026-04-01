import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 👈 નવું ઈમ્પોર્ટ
import 'role_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  // 🚀 Google Sign-In નું જાદુઈ ફંક્શન (100% Mobile માટે સાચું)
  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      // ૧. મોબાઈલ માં ગૂગલ એકાઉન્ટ સિલેક્ટ કરવાનું પોપ-અપ
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // જો યુઝર કોઈ એકાઉન્ટ સિલેક્ટ કર્યા વગર Back દબાવી દે તો લોડીંગ બંધ કરો
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      // ૨. ગૂગલ પાસેથી ઓથોરાઈઝેશન (ટોકન) લેવા
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ૩. ફાયરબેઝ માટે ક્રેડેન્શિયલ બનાવવા
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ૪. ફાયરબેઝ માં લોગીન કરાવવું 
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        setState(() => isLoading = false);

        // યુઝરનું નામ લઈને વેલકમ મેસેજ બતાવશે!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome ${userCredential.user!.displayName}! 🎉"), backgroundColor: Colors.green)
        );

        // લોગીન થાય એટલે સીધું Boss/Employee પેજ પર!
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RoleScreen()));
      }
    } catch (e) {
      // એરર આવે એટલે લોડીંગ બંધ કરવા 
      setState(() => isLoading = false);

      // એરર સ્ક્રીન પર દેખાડવા
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // 🏢 તમારો MyStaff લોગો
              Center(
                child: Image.asset('assets/logo.png', height: 120, errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business_center, size: 100, color: Color(0xFF1565C0));
                }),
              ),
              const SizedBox(height: 30),

              const Text("Welcome to MyStaff 👋", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 10),
              const Text("Log in securely with your Google account. No passwords, no OTPs, 100% free!", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5)),

              const SizedBox(height: 50),

              // 🚀 મસ્ત પ્રીમિયમ Google બટન
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.shade300)
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(strokeWidth: 3))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google નો અસલી 'G' લોગો
                            Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png", height: 24),
                            const SizedBox(width: 15),
                            const Text("Continue with Google", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                ),
              ),

              const Spacer(),
              const Text("By continuing, you agree to our Terms & Privacy Policy.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}