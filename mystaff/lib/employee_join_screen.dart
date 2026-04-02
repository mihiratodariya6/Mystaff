import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:csc_picker_plus/csc_picker_plus.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// 👈 તારા ડેશબોર્ડની ફાઈલ ઈમ્પોર્ટ કરવી પડશે
import 'employee_dashboard_screen.dart'; 

class EmployeeJoinScreen extends StatefulWidget {
  final String userPhone;
  const EmployeeJoinScreen({super.key, this.userPhone = "+91 99242 47523"});

  @override
  State<EmployeeJoinScreen> createState() => _EmployeeJoinScreenState();
}

class _EmployeeJoinScreenState extends State<EmployeeJoinScreen> {
  File? _image;
  final picker = ImagePicker();
  bool isLoading = false;

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final surnameController = TextEditingController();
  final dobController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final aadharController = TextEditingController();
  final panController = TextEditingController();
  final inviteCodeController = TextEditingController();

  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  String? selectedDesignation;

  List<String> designations = [
    'General Manager', 'HR Manager', 'Accountant', 'Sales Executive', 
    'Receptionist', 'Software Engineer', 'Project Manager', 
    'Office Assistant', 'Driver', 'Security Guard', 'Operations Head', 'Other'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dobController.text = "${picked.day}/${picked.month}/${picked.year}");
    }
  }

  // 🚀 આ ફંક્શનમાં મેં અસલી જાદુ ઉમેર્યો છે (Auto-Join Logic)
  Future<void> handleFinalJoin() async {
    String enteredCode = inviteCodeController.text.trim().toUpperCase();

    if (firstNameController.text.isEmpty || surnameController.text.isEmpty || selectedDesignation == null || enteredCode.isEmpty) {
      _showMessage("Error: Name, Designation and Invite Code are required!", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔍 ૧. ડેટાબેઝમાં ચેક કરો કે આ કંપની કોડ (Invite Code) સાચો છે?
      var companyDoc = await FirebaseFirestore.instance.collection('companies').doc(enteredCode).get();

      if (!companyDoc.exists) {
        setState(() => isLoading = false);
        _showMessage("Invalid Invite Code! Please check with your Boss. ❌", Colors.red);
        return;
      }

      // ૨. જો કંપની મળી જાય, તો એનું નામ ખેંચી લો
      String companyNameFromDb = companyDoc['companyName'] ?? "My Company";

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ૩. ફાયરબેઝમાં એમ્પ્લોઈના ડેટામાં કંપનીની વિગતો લિંક કરો
        await FirebaseFirestore.instance.collection('employees').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstNameController.text.trim(),
          'middleName': middleNameController.text.trim(),
          'surname': surnameController.text.trim(),
          'name': "${firstNameController.text.trim()} ${surnameController.text.trim()}",
          'dob': dobController.text,
          'email': emailController.text.trim(),
          'phone': widget.userPhone,
          'emergencyPhone': emergencyContactController.text.trim(),
          'companyCode': enteredCode, // 👈 આ ચાવી છે
          'companyName': companyNameFromDb, // 👈 નામ પણ અહીં જ સેવ કરી લઈએ
          'address': addressController.text.trim(),
          'city': cityValue,
          'state': stateValue,
          'country': countryValue,
          'role': selectedDesignation,
          'aadhar': aadharController.text.trim(),
          'pan': panController.text.trim(),
          'isApproved': false, 
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ૪. મોબાઈલની મેમરીમાં (Local Cache) પણ સેવ કરો
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', 'employee');
        await prefs.setString('company_code', enteredCode);

        setState(() => isLoading = false);
        _showMessage("Registered Successfully! Joined $companyNameFromDb 🎉", Colors.green);
        
        // ૫. રજીસ્ટ્રેશન પછી સીધું ડેશબોર્ડ પર મોકલી દો!
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()));
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Staff Registration", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue.shade50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null ? const Icon(Icons.add_a_photo_outlined, size: 35, color: Color(0xFF1565C0)) : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("Company Details"),
            _buildTextField(inviteCodeController, "Company Invite Code (Ex: ABC-1234)", Icons.vpn_key),
            
            const SizedBox(height: 25),

            _buildSectionTitle("Personal Information"),
            Row(
              children: [
                Expanded(child: _buildTextField(firstNameController, "First Name", Icons.person)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(middleNameController, "Middle Name", Icons.person_outline)),
              ],
            ),
            _buildTextField(surnameController, "Surname / Last Name", Icons.people_outline),
            
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(child: _buildTextField(dobController, "Date of Birth", Icons.calendar_today)),
            ),
            
            _buildTextField(emailController, "Official Email ID", Icons.email_outlined),
            _buildTextField(null, widget.userPhone, Icons.phone_android, enabled: false),
            _buildTextField(emergencyContactController, "Emergency Contact Number", Icons.contact_phone_outlined),

            const SizedBox(height: 25),

            _buildSectionTitle("Permanent Address"),
            CSCPickerPlus(
              layout: Layout.vertical,
              onCountryChanged: (value) => setState(() => countryValue = value),
              onStateChanged: (value) => setState(() => stateValue = value),
              onCityChanged: (value) => setState(() => cityValue = value),
              defaultCountry: CscCountry.India,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1)
              ),
              selectedItemStyle: const TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildTextField(addressController, "House No, Street, Landmark", Icons.home_outlined),

            const SizedBox(height: 25),

            _buildSectionTitle("Work Designation"),
            _buildDropdown("Select Your Role", designations, selectedDesignation, (val) => setState(() => selectedDesignation = val)),

            const SizedBox(height: 25),

            _buildSectionTitle("Identity Documents"),
            _buildTextField(aadharController, "Aadhar Card Number", Icons.fingerprint),
            _buildTextField(panController, "PAN Card Number", Icons.credit_card),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleFinalJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Register & Join Team", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1565C0), letterSpacing: 1.2))));
  }

  Widget _buildTextField(TextEditingController? controller, String hint, IconData icon, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller, enabled: enabled,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          filled: true, fillColor: enabled ? Colors.white : Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentVal, Function(String?) onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label, style: const TextStyle(fontSize: 14)), value: currentVal, isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }
}