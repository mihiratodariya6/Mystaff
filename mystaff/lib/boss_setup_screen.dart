import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'boss_dashboard_screen.dart';

class BossSetupScreen extends StatefulWidget {
  const BossSetupScreen({super.key});

  @override
  State<BossSetupScreen> createState() => _BossSetupScreenState();
}

class _BossSetupScreenState extends State<BossSetupScreen> {
  int _currentStep = 0;
  bool isSaving = false; 

  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController gstController = TextEditingController(); 
  String selectedBusinessType = 'IT / Tech';
  String selectedCompanySize = '1-10 Employees';

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String selectedTiming = '09:00 AM - 06:00 PM';
  String selectedDays = 'Mon - Sat';

  String generateCompanyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    String prefix = String.fromCharCodes(Iterable.generate(3, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    String suffix = (random.nextInt(9000) + 1000).toString();
    return '$prefix-$suffix';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ $msg"), backgroundColor: Colors.red));
  }

  void _finishSetup() async { 
    String compName = companyNameController.text.trim();
    String gst = gstController.text.trim().toUpperCase();

    if (compName.isEmpty) {
      _showError("Company Name is required!"); return;
    }

    if (gst.isNotEmpty) {
      if (!RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$').hasMatch(gst)) {
        _showError("Invalid GST Number! Format should be 22ABCDE1234F1Z5"); return;
      }
    }

    setState(() => isSaving = true);

    String uid = FirebaseAuth.instance.currentUser!.uid; 
    String newCode = generateCompanyCode();

    try {
      // 🚀 ૧. ચેક કરો કે આ કોડ કોઈ બીજી કંપની પાસે તો નથી ને?
      var existingCompany = await FirebaseFirestore.instance.collection('companies').doc(newCode).get();
      if (existingCompany.exists) {
        newCode = generateCompanyCode(); // જો હોય તો ફરીથી નવો બનાવો
      }

      // ☁️ ૨. કંપનીનો ડેટા સેવ કરો
      await FirebaseFirestore.instance.collection('companies').doc(newCode).set({
        'bossId': uid,
        'companyCode': newCode,
        'companyName': compName,
        'gstNumber': gst,
        'businessType': selectedBusinessType,
        'companySize': selectedCompanySize,
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'workingDays': selectedDays,
        'timings': selectedTiming,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 👤 ૩. બોસની પોતાની પ્રોફાઈલમાં કંપની કોડ અને રોલ અપડેટ કરો
      await FirebaseFirestore.instance.collection('bosses').doc(uid).set({
        'uid': uid,
        'name': FirebaseAuth.instance.currentUser?.displayName ?? "Boss",
        'role': 'boss',
        'companyCode': newCode,
      }, SetOptions(merge: true));

      // 💾 ૪. મોબાઈલ મેમરીમાં સેવ કરો
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'boss');
      await prefs.setString('company_code', newCode);

      setState(() => isSaving = false);

      if (mounted) {
        _showSuccessDialog(newCode, compName);
      }
    } catch (e) {
      setState(() => isSaving = false);
      _showError("Error: ${e.toString()}");
    }
  }

  void _showSuccessDialog(String code, String name) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(children: [Icon(Icons.check_circle, color: Colors.green, size: 60), SizedBox(height: 10), Text("Setup Complete! 🎉", style: TextStyle(fontWeight: FontWeight.bold))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Share this code with your employees to join your workspace:", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1565C0))), child: Text(code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Color(0xFF1565C0)))),
          ],
        ),
        actions: [
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BossDashboardScreen(companyName: name, companyId: code)));}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Set Up Workspace", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: Theme(
        data: ThemeData(colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0))),
        child: isSaving 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Creating your workspace...")] )) 
        : Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) setState(() => _currentStep += 1);
            else _finishSetup();
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep -= 1);
          },
          steps: [
            Step(title: const Text("Company Profile", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 0, content: Column(children: [_buildTextField("Company Name *", "e.g. MyStaff Solutions", Icons.business, companyNameController), const SizedBox(height: 15), _buildTextField("GST Number (Optional)", "e.g. 22ABCDE1234F1Z5", Icons.receipt_long, gstController, maxLength: 15), const SizedBox(height: 15), _buildDropdown("Business Type", ['IT / Tech', 'Sales / Retail', 'Logistics', 'Manufacturing', 'Service', 'Other'], selectedBusinessType, (val) => setState(() => selectedBusinessType = val!)), const SizedBox(height: 15), _buildDropdown("Company Size", ['1-10 Employees', '11-50 Employees', '51-200 Employees', '200+ Employees'], selectedCompanySize, (val) => setState(() => selectedCompanySize = val!))])),
            Step(title: const Text("Office Details", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 1, content: Column(children: [_buildTextField("Office Address", "e.g. 404, Business Hub", Icons.location_on, addressController), const SizedBox(height: 15), _buildTextField("City / State", "e.g. Surat, Gujarat", Icons.location_city, cityController), const SizedBox(height: 15), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.pin_drop, color: Colors.red), label: const Text("Pin Location on Map"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))))])),
            Step(title: const Text("Work Configuration", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 2, content: Column(children: [_buildDropdown("Working Days", ['Mon - Sat', 'Mon - Fri', 'Custom'], selectedDays, (val) => setState(() => selectedDays = val!)), const SizedBox(height: 15), _buildDropdown("Office Timings", ['09:00 AM - 06:00 PM', '10:00 AM - 07:00 PM', 'Night Shift (08 PM - 05 AM)', 'Custom'], selectedTiming, (val) => setState(() => selectedTiming = val!)), const SizedBox(height: 15), Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)), child: const Row(children: [Icon(Icons.security, color: Colors.orange), SizedBox(width: 10), Expanded(child: Text("2-Step Verification and Live Location Tracking will be enabled.", style: TextStyle(fontSize: 12, color: Colors.black87)))]))])),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, TextEditingController controller, {int? maxLength}) {
    return TextField(controller: controller, maxLength: maxLength, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF1565C0)), filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)), counterText: ""));
  }

  Widget _buildDropdown(String label, List<String> items, String selectedValue, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(value: selectedValue, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300))), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged);
  }
}