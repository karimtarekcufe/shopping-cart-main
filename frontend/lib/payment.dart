import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_app/config.dart';  // Assuming your Stripe keys are here

// Define the base URL for your API
const String apiBaseUrl = 'http://10.0.2.2:3000'; // Replace with your actual API base URL

class PaymentPage extends StatefulWidget {
  final double amount;
  final String token;
  final List<Map<String, dynamic>> items;

  const PaymentPage({
    Key? key,
    required this.amount,
    required this.token,
    required this.items,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isLoading = false;
  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '\$${item['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const Divider(thickness: 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Payment Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => makePayment(),
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.payment),
              label: Text(
                _isLoading ? "Processing..." : "Pay \$${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Payment methods info
            const Center(
              child: Text(
                'We accept Visa, Mastercard, and American Express',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Security message
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Secure payment processing by Stripe',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Create payment intent on the server
      paymentIntent = await createPaymentIntent();
      
      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'Shopping App',
          // You can customize appearance here
          style: ThemeMode.light,
          // You can add billing details if needed
        ),
      );
      
      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      
      // 4. Payment successful
      paymentSuccessful();
      
    } catch (e) {
      // Payment failed
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent() async {
    // This endpoint should be implemented on your backend
    final url = Uri.parse('$apiBaseUrl/create-payment-intent');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'amount': (widget.amount * 100).toInt(), // Amount in cents
          'currency': 'usd',
          'items': widget.items
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw 'Failed to create payment intent. Server returned: ${response.body}';
      }
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  void paymentSuccessful() {
    setState(() {
      _isLoading = false;
    });
    
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: const Text('Your order has been placed successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Navigate back to items page and clear the cart
              Navigator.popUntil(context, ModalRoute.withName('/items'));
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}