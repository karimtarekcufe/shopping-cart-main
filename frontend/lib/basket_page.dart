import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final String token;

  const CartPage({super.key, required this.cart, required this.token});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late SharedPreferences prefs;
  List<Map<String, dynamic>> userCart = [];
  bool _isProcessing = false; // Add this flag for processing state

  @override
  void initState() {
    super.initState();
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    loadUserCart();
  }

  void loadUserCart() {
    String? cartString = prefs.getString('cart_${widget.token}');
    if (cartString != null) {
      List<dynamic> decodedCart = jsonDecode(cartString);
      setState(() {
        userCart = List<Map<String, dynamic>>.from(decodedCart);
        // Merge with any new items from widget.cart
        for (var item in widget.cart) {
          if (!userCart.any(
            (element) =>
                element['name'] == item['name'] &&
                element['price'] == item['price'],
          )) {
            userCart.add(item);
          }
        }
      });
    } else {
      setState(() {
        userCart = [...widget.cart];
      });
    }
    saveUserCart();
  }

  void saveUserCart() {
    prefs.setString('cart_${widget.token}', jsonEncode(userCart));
  }

  double getTotalPrice() {
    return userCart.fold(0, (sum, item) => sum + (item['price'] as num));
  }

  // Validate cart items before checkout
  bool _validateCart() {
    if (userCart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty! Add items before checking out.'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    // Validate each item in cart
    for (var item in userCart) {
      if (!_validateItem(item)) {
        return false;
      }
    }
    return true;
  }

  // Validate individual item
  bool _validateItem(Map<String, dynamic> item) {
    if (!item.containsKey('name') || item['name'].toString().isEmpty) {
      _showError('Invalid item: Missing name');
      return false;
    }

    if (!item.containsKey('price') ||
        item['price'] == null ||
        (item['price'] as num) <= 0) {
      _showError('Invalid item: Invalid price for ${item['name']}');
      return false;
    }

    return true;
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Modified checkout method with validation
  Future<void> checkout() async {
    if (_isProcessing) return; // Prevent multiple clicks

    if (!_validateCart()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate checkout process
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        userCart.clear();
        saveUserCart();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout successful! Thank you for your purchase.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Checkout failed: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Modified removeItem with validation
  void removeItem(int index) {
    if (index < 0 || index >= userCart.length) {
      _showError('Invalid item index');
      return;
    }

    setState(() {
      userCart.removeAt(index);
      saveUserCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Basket')),
      body:
          userCart.isEmpty
              ? const Center(child: Text('Your cart is empty!'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: userCart.length,
                      itemBuilder: (context, index) {
                        final item = userCart[index];
                        return Dismissible(
                          key: Key(item['name']),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => removeItem(index),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                item['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item['description'] != null)
                                    Text(item['description']),
                                  Text(
                                    '\$${item['price']}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => removeItem(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total: \$${getTotalPrice().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : checkout,
                          icon:
                              _isProcessing
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
                            _isProcessing ? "Processing..." : "Checkout",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context),
        label: const Text("Back to Items"),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}
