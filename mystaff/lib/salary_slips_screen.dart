import 'package:flutter/material.dart';

class SalarySlipsScreen extends StatelessWidget {
  const SalarySlipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text("Salary Slips", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSlipCard(context, "March 2026", "Generated on 31 Mar", "₹ 45,000"),
          _buildSlipCard(context, "February 2026", "Generated on 28 Feb", "₹ 45,000"),
          _buildSlipCard(context, "January 2026", "Generated on 31 Jan", "₹ 42,000"), // Increment example
        ],
      ),
    );
  }

  Widget _buildSlipCard(BuildContext context, String month, String date, String amount) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.request_quote, color: Colors.green)),
        title: Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0), fontSize: 15)),
            const Text("Download", style: TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.underline)),
          ],
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Downloading Salary Slip for $month... 📄")));
        },
      ),
    );
  }
}