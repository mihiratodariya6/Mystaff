import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'employee_dashboard_screen.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  const EmployeeDetailsScreen({super.key});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  int _currentStep = 0;
  bool isVerifying = false; 

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController panController = TextEditingController(); // 👈 નવું
  final TextEditingController aadharController = TextEditingController(); // 👈 નવું
  final TextEditingController compCodeController = TextEditingController();
  
  final List<String> jobRoles = ['Manager', 'Team Lead', 'Sales Executive', 'Developer', 'Accountant', 'HR Executive', 'Customer Support', 'Other'];
  final List<String> departments = ['Management', 'HR & Admin', 'Finance & Accounts', 'IT / Tech', 'Sales', 'Marketing', 'Operations', 'Other'];

  String selectedRole = 'Sales Executive';
  String selectedDept = 'Sales';
  String empId = "";
  bool locationGranted = false;

  @override
  void initState() {
    super.initState();
    empId = "EMP-${(Random().nextInt(9000) + 1000)}";
  }

  // 🛡️ કડક ચેકિંગ (Validation Rules)
  bool _validateStep1() {
    String email = emailController.text.trim();
    String pan = panController.text.trim().toUpperCase();
    String aadhar = aadharController.text.trim();

    // 1. Name Check
    if (nameController.text.trim().isEmpty) {
      _showError("Please enter your Full Name!"); return false;
    }
    // 2. Gmail Check
    if (!RegExp(r'^[a-zA-Z0-9.]+@gmail\.com$').hasMatch(email)) {
      _showError("Invalid Email! Must be a valid @gmail.com address."); return false;
    }
    // 3. PAN Card Check (5 Letters, 4 Digits, 1 Letter)
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      _showError("Invalid PAN! Format should be like ABCDE1234F"); return false;
    }
    // 4. Aadhar Card Check (Exactly 12 Digits)
    if (!RegExp(r'^[0-9]{12}$').hasMatch(aadhar)) {
      _showError("Invalid Aadhar! Must be exactly 12 digits."); return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ $msg"), backgroundColor: Colors.red));
  }

  void _finishSetup() async {
    String enteredCode = compCodeController.text.trim().toUpperCase();

    // 5. Company Code Check (3 Letters, Hyphen, 4 Digits)
    if (!RegExp(r'^[A-Z]{3}-[0-9]{4}$').hasMatch(enteredCode)) {
      _showError("Invalid Company Code! Format must be like ABC-1234"); return;
    }

    setState(() => isVerifying = true); 

    try {
      DocumentSnapshot companyDoc = await FirebaseFirestore.instance.collection('companies').doc(enteredCode).get();

      if (!companyDoc.exists) {
        setState(() => isVerifying = false);
        _showError("Company Code not found in database! Please check again."); return;
      }

      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('employees').doc(uid).set({
        'empId': empId,
        'uid': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'panCard': panController.text.trim().toUpperCase(),
        'aadharCard': aadharController.text.trim(),
        'role': selectedRole,
        'department': selectedDept,
        'companyCode': enteredCode, 
        'joinedAt': FieldValue.serverTimestamp(),
      });
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'employee');
      await prefs.setString('company_code', enteredCode);

      setState(() => isVerifying = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Joined Successfully! 🎉"), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()));
      }
    } catch (e) {
      setState(() => isVerifying = false);
      _showError("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Employee Setup", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0),
      body: Theme(
        data: ThemeData(colorScheme: const ColorScheme.light(primary: Color(0xFF1565C0))),
        child: isVerifying
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Verifying Company Code... 🔍")]))
        : Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            // અહી આપણે ચેક કરીશું કે ડેટા સાચો છે કે નહિ
            if (_currentStep == 0 && !_validateStep1()) return; 
            if (_currentStep == 2 && !locationGranted) {
              _showError("Please grant location permission! 📍"); return;
            }
            if (_currentStep < 3) setState(() => _currentStep += 1);
            else _finishSetup();
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep -= 1);
          },
          steps: [
            Step(title: const Text("Personal Info", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 0, content: Column(children: [
              _buildField("Full Name *", Icons.person, nameController, "e.g. Rahul Sharma"), const SizedBox(height: 10), 
              _buildField("Gmail ID *", Icons.email, emailController, "e.g. rahul@gmail.com"), const SizedBox(height: 10),
              _buildField("PAN Card No *", Icons.credit_card, panController, "e.g. ABCDE1234F", maxLength: 10), const SizedBox(height: 10),
              _buildField("Aadhar Card No *", Icons.fingerprint, aadharController, "e.g. 123456789012", isNumber: true, maxLength: 12)
            ])),
            Step(title: const Text("Work Details", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 1, content: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), child: Text("Your Auto-Generated ID: $empId", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0)))), const SizedBox(height: 15), _buildDropdown("Job Role", jobRoles, selectedRole, (v) => setState(() => selectedRole = v!)), const SizedBox(height: 10), _buildDropdown("Department", departments, selectedDept, (v) => setState(() => selectedDept = v!))])),
            Step(title: const Text("Tracking", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 2, content: Column(children: [const Text("Live location tracking is required.", style: TextStyle(color: Colors.grey)), const SizedBox(height: 15), ElevatedButton.icon(onPressed: () {setState(() => locationGranted = true); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location Access Granted! ✅"), backgroundColor: Colors.green));}, icon: Icon(locationGranted ? Icons.check_circle : Icons.my_location, color: Colors.white), label: Text(locationGranted ? "Permission Granted" : "Allow Live Location"), style: ElevatedButton.styleFrom(backgroundColor: locationGranted ? Colors.green : const Color(0xFF1565C0)))])),
            Step(title: const Text("Join Company", style: TextStyle(fontWeight: FontWeight.bold)), isActive: _currentStep >= 3, content: Column(children: [const Text("Enter 8-digit code (e.g. TRK-4582)"), const SizedBox(height: 10), _buildField("Company Code *", Icons.business, compCodeController, "ABC-1234")])),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController c, String hint, {bool isNumber = false, int? maxLength}) => TextField(controller: c, keyboardType: isNumber ? TextInputType.number : TextInputType.text, maxLength: maxLength, decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), counterText: ""));
  Widget _buildDropdown(String label, List<String> items, String val, Function(String?) onChange) => DropdownButtonFormField(value: val, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChange, decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))));
}