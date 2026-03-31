import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionScreen extends StatefulWidget {
  final String companyCode;
  const SubscriptionScreen({super.key, required this.companyCode});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // પેમેન્ટ સફળ થાય ત્યારે ડેટાબેઝમાં પ્લાન અપડેટ કરો
    await FirebaseFirestore.instance.collection('companies').doc(widget.companyCode).update({
      'plan': 'PRO',
      'paymentId': response.paymentId,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful! Welcome to PRO 🎉"), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: ${response.message}"), backgroundColor: Colors.red));
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_YOUR_KEY', // અહી તમારી કી આવશે
      'amount': 49900, // ₹499
      'name': 'MyStaff Solutions',
      'description': 'PRO Plan Subscription',
      'prefill': {'contact': '', 'email': ''},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade to PRO")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text("Unlock All Features for ₹499/mo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: openCheckout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: const Text("Pay Now & Upgrade"),
            )
          ],
        ),
      ),
    );
  }
}