import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 કંપની કોડ માટે
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MonthlyAttendanceReport extends StatefulWidget {
  const MonthlyAttendanceReport({super.key});

  @override
  State<MonthlyAttendanceReport> createState() => _MonthlyAttendanceReportState();
}

class _MonthlyAttendanceReportState extends State<MonthlyAttendanceReport> {
  String selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  bool isGenerating = false;

  // 📅 મહિનો બદલવા માટેનું ફંક્શન
  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: "SELECT REPORT MONTH",
    );
    if (picked != null) {
      setState(() {
        selectedMonth = DateFormat('yyyy-MM').format(picked);
      });
    }
  }

  // 📥 ડેટાબેઝમાંથી આખા મહિનાનો ડેટા ખેંચી લાવશે
  Future<List<List<String>>> _getAttendanceData() async {
    // 🚀 અસલી કંપની કોડ મેમરીમાંથી લાવશે
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String companyId = prefs.getString('company_code') ?? "";

    if (companyId.isEmpty) return [['No Data Found']];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('companyId', isEqualTo: companyId)
        .orderBy('date', descending: true)
        .get();

    List<List<String>> data = [
      ['Date', 'Employee Name', 'Check In', 'Check Out', 'Status']
    ];

    for (var doc in snapshot.docs) {
      String date = doc['date'] ?? "";
      // જો તારીખ પસંદ કરેલા મહિનાથી શરુ થતી હોય તો જ એડ કરો
      if (date.startsWith(selectedMonth)) {
        data.add([
          date,
          doc['empName'] ?? "N/A",
          doc['checkIn'] ?? "--:--",
          doc['checkOut'] ?? "--:--",
          doc['status'] ?? "Present"
        ]);
      }
    }
    return data;
  }

  // 🖨️ PDF રિપોર્ટ બનાવવાનો જાદુ
  void _generatePdfReport() async {
    setState(() => isGenerating = true);
    
    try {
      final pdf = pw.Document();
      final attendanceData = await _getAttendanceData();

      if (attendanceData.length <= 1) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No attendance records found for this month!")));
        setState(() => isGenerating = false);
        return;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Monthly Attendance Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Text("Month: $selectedMonth", style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: attendanceData[0],
                data: attendanceData.sublist(1),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellHeight: 25,
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
              ),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Generated via MyStaff App", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey))
              )
            ];
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Company Reports", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Month for Report", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade100)),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF1565C0)),
                  const SizedBox(width: 15),
                  Text(DateFormat('MMMM yyyy').format(DateTime.parse("$selectedMonth-01")), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
                  const Spacer(),
                  TextButton(onPressed: _selectMonth, child: const Text("Change", style: TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text("Available Reports", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            const SizedBox(height: 15),

            _reportCard(
              "Full Attendance Sheet (PDF)", 
              "Includes In/Out timings for all staff", 
              Icons.picture_as_pdf, 
              Colors.red, 
              isGenerating ? null : _generatePdfReport
            ),
            
            const SizedBox(height: 15),

            _reportCard(
              "Export to Excel (.xlsx)", 
              "Best for calculated salary processing", 
              Icons.table_view, 
              Colors.green, 
              () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Excel Export coming in Pro Version! 💳"), backgroundColor: Colors.orange))
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(String title, String sub, IconData icon, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            if (isGenerating && title.contains("PDF"))
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              const Icon(Icons.download, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}