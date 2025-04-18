import 'package:flutter/material.dart';
import 'package:booking/services/razorpay_services.dart';

class StudentPayFeesPage extends StatefulWidget {
  @override
  _StudentPayFeesPageState createState() => _StudentPayFeesPageState();
}

class _StudentPayFeesPageState extends State<StudentPayFeesPage> {
  RazorpayService razorpayService = RazorpayService();

  @override
  void dispose() {
    razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pay Fees")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Fees: ₹1", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("First Installment: ₹0.5 - ✅ Paid"),
            SizedBox(height: 10),
            Text("Second Installment: ₹0.5 - ❌ Pending"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                razorpayService.openCheckout(1); // Pay ₹25,000
              },
              child: Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
