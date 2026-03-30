import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 
import 'boss_dashboard_screen.dart'; // 👈 Dashboard link kari didhu

class BossSetupScreen extends StatefulWidget {
  final String userPhone;
  const BossSetupScreen({super.key, this.userPhone = "+91 99242 47523"});

  @override
  State<BossSetupScreen> createState() => _BossSetupScreenState();
}

class _BossSetupScreenState extends State<BossSetupScreen> {
  File? _image; 
  final picker = ImagePicker();

  // Controllers
  final ownerNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final gstController = TextEditingController(); 
  final panController = TextEditingController(); 
  final websiteController = TextEditingController(); 
  
  String businessType = 'Office';
  String totalEmployees = '1-10';
  bool isLoading = false;

  // 📸 Logo Selection
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) _image = File(pickedFile.path);
    });
  }

  // 🔍 PAN Validation (5 Letters + 4 Digits + 1 Letter)
  bool isValidPAN(String pan) {
    RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(pan.toUpperCase());
  }

  // 🔍 GST Verification & Auto-fill Logic
  void verifyGST() async {
    String gst = gstController.text.trim();
    if (gst.length != 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bapu, GST number 15 akda no hoy!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { isLoading = true; });
    await Future.delayed(const Duration(seconds: 2)); // ⏳ Dummy API
    
    setState(() {
      isLoading = false;
      companyNameController.text = "Mihir Enterprises Pvt Ltd";
      addressController.text = "402, Business Hub, Ring Road";
      cityController.text = "Surat, Gujarat";
      panController.text = gst.substring(2, 12).toUpperCase();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("GST Verified & Details Auto-filled! ✅"), backgroundColor: Colors.green),
    );
  }

  // 🚀 Final Registration Logic
  void handleCreateCompany() async {
    String pan = panController.text.trim();

    if (pan.isNotEmpty && !isValidPAN(pan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PAN Format Invalid! (Ex: ABCDE1234F)"), backgroundColor: Colors.red),
      );
      return;
    }

    if (ownerNameController.text.isEmpty || companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Owner & Company Name are required!")));
      return;
    }

    setState(() { isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { isLoading = false; });

    String generatedId = "MS-${companyNameController.text.substring(0,2).toUpperCase()}${DateTime.now().millisecond}";

    if (!mounted) return;
    
    // 🎊 Success Pop-up with Dashboard Navigation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("Registration Success! 🎊")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            Text("Admin Role Assigned for ${companyNameController.text}"),
            const SizedBox(height: 10),
            const Text("Your Company ID:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(generatedId, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Pop-up bandh
                
                // 👇 SIDHU DASHBOARD PAR (Pacha na aavi shakay)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BossDashboardScreen(
                      companyName: companyNameController.text,
                      companyId: generatedId,
                    ),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Boss Profile Setup", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 📸 LOGO
            Center(
              child: GestureDetector(
                onTap: _pickImage, 
                child: Stack(
                  children: [
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1565C0), width: 2),
                        image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                      ),
                      child: _image == null ? const Icon(Icons.business, size: 50, color: Color(0xFF1565C0)) : null,
                    ),
                    Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF1565C0), shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("👤 Owner Details"),
            _buildTextField(ownerNameController, "Owner Full Name", Icons.person_outline),
            _buildTextField(null, widget.userPhone, Icons.phone_android, enabled: false),
            _buildTextField(emailController, "Personal Email", Icons.email_outlined),
            
            const SizedBox(height: 20),

            _buildSectionTitle("📜 GST & Legal Info"),
            Row(
              children: [
                Expanded(child: _buildTextField(gstController, "GST Number", Icons.verified_user_outlined)),
                const SizedBox(width: 10),
                Container(
                  height: 55, margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: verifyGST,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Verify", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            _buildTextField(panController, "PAN Card Number (Ex: ABCDE1234F)", Icons.credit_card),

            const SizedBox(height: 20),

            _buildSectionTitle("🏢 Company Details"),
            _buildTextField(companyNameController, "Company Name", Icons.storefront),
            _buildTextField(websiteController, "Website (Optional)", Icons.language),
            _buildTextField(addressController, "Office Address", Icons.location_on_outlined),
            _buildTextField(cityController, "City / State", Icons.map_outlined),

            const SizedBox(height: 20),

            _buildSectionTitle("💼 Business Profile"),
            _buildDropdown("Category", ['Office', 'Shop', 'Startup', 'Factory'], businessType, (val) => setState(() => businessType = val!)),
            _buildDropdown("Staff Size", ['1-10', '11-50', '51-200', '200+'], totalEmployees, (val) => setState(() => totalEmployees = val!)),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleCreateCompany,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Register Company", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))));
  }

  Widget _buildTextField(TextEditingController? controller, String hint, IconData icon, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller, enabled: enabled,
        decoration: InputDecoration(
          hintText: hint, prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          filled: true, fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentVal, Function(String?) onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: currentVal, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChange)),
    );
  }
}