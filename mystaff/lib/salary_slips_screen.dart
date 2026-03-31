import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

// 🚀 PDF માટેના પેકેજ
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalarySlipsScreen extends StatefulWidget {
  const SalarySlipsScreen({super.key});

  @override
  State<SalarySlipsScreen> createState() => _SalarySlipsScreenState();
}

class _SalarySlipsScreenState extends State<SalarySlipsScreen> {
  String empName = "Loading...";
  String empRole = "";
  String companyCode = "";
  int presentDays = 0;
  final int totalDaysInMonth = 30;
  final double fixedMonthlySalary = 30000.0; // 👈 ધારો કે ફિક્સ પગાર 30,000 છે

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDataAndCalculateSalary();
  }

  // 🧮 ડેટાબેઝમાંથી હાજરી અને ડેટા લાવીને પગાર ગણશે
  void _fetchDataAndCalculateSalary() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 1. એમ્પ્લોઈનો ડેટા લાવો
      DocumentSnapshot empDoc = await FirebaseFirestore.instance.collection('employees').doc(user.uid).get();
      if (empDoc.exists) {
        empName = empDoc['name'] ?? "Staff";
        empRole = empDoc['role'] ?? "Employee";
        companyCode = empDoc['companyCode'] ?? "";
      }

      // 2. આ મહિનાની હાજરી ગણો (Present Days)
      String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      QuerySnapshot attendance = await FirebaseFirestore.instance
          .collection('attendance')
          .where('companyId', isEqualTo: companyCode)
          .where('empName', isEqualTo: empName)
          .get();

      int count = 0;
      for (var doc in attendance.docs) {
        String date = doc['date']; // 2024-03-25
        if (date.startsWith(currentMonth)) {
          count++;
        }
      }

      setState(() {
        presentDays = count;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // 🖨️ PDF બનાવવાનું ફંક્શન
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // 💰 પગારની ગણતરી
    double perDaySalary = fixedMonthlySalary / totalDaysInMonth;
    double basicPay = perDaySalary * presentDays;
    double deductions = fixedMonthlySalary - basicPay;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // 🏢 Company Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("MYSTAFF SOLUTIONS PVT. LTD.", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text("Surat, Gujarat, India | Code: $companyCode", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                      pw.SizedBox(height: 20),
                      pw.Text("SALARY SLIP", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                      pw.Text("Month: ${DateFormat('MMMM yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 40),

                // 👨‍💼 Employee Details
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey)),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Employee Name: $empName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text("Designation: $empRole"),
                        ]
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text("Total Days: $totalDaysInMonth"),
                          pw.Text("Days Present: $presentDays", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ]
                      )
                    ]
                  )
                ),
                pw.SizedBox(height: 30),

                // 💵 Salary Details Table
                pw.TableHelper.fromTextArray(
                  headers: ['Description', 'Amount (INR)'],
                  data: [
                    ['Fixed Monthly Salary', fixedMonthlySalary.toStringAsFixed(2)],
                    ['Basic Pay (Based on Attendance)', basicPay.toStringAsFixed(2)],
                    ['Leave Deductions', '- ${deductions.toStringAsFixed(2)}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  cellHeight: 30,
                  cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
                ),
                pw.Divider(),
                
                // 💰 Net Payable
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("NET PAYABLE: Rs. ${basicPay.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
                pw.Spacer(),

                // ✍️ Signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(children: [pw.Container(width: 100, height: 1, color: PdfColors.black), pw.SizedBox(height: 5), pw.Text("Employee Signature")]),
                    pw.Column(children: [pw.Container(width: 100, height: 1, color: PdfColors.black), pw.SizedBox(height: 5), pw.Text("Employer Signature")]),
                  ]
                ),
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text("This is a computer-generated document and does not require physical signatures.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)))
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Salary Slips", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black), elevation: 1),
      
      // 🚀 PDF Preview બતાવશે
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : PdfPreview(
            build: (format) => _generatePdf(format),
            allowPrinting: true,
            allowSharing: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            pdfFileName: "Salary_Slip_${empName.replaceAll(' ', '_')}.pdf",
          ),
    );
  }
}