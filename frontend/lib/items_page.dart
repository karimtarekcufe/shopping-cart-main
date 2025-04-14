import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/config.dart';
import 'dart:convert';
import 'basket_page.dart';
import 'login_page.dart';

class ItemsPage extends StatefulWidget {
  final String token;
  const ItemsPage({required this.token, super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late String email;
  late SharedPreferences prefs;
  List<Map<String, dynamic>> cart = [];
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    email = jwtDecodedToken['email'];
    // Call fetchItems after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchItems();
    });
    initSharedPrefs();
  }

  void initSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    loadCart();
  }

  void loadCart() {
    String? cartString = prefs.getString('cart_${widget.token}');
    if (cartString != null) {
      List<dynamic> decodedCart = jsonDecode(cartString);
      setState(() {
        cart = List<Map<String, dynamic>>.from(decodedCart);
      });
    }
  }

  void saveCart() {
    prefs.setString('cart_${widget.token}', jsonEncode(cart));
  }

  Future<void> fetchItems() async {
    try {
      print('Fetching items from: $getItems');

      final response = await http.get(
        Uri.parse(getItems),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Decoded data: $responseData');

        // Check if responseData is in the expected format
        if (responseData is Map &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          setState(() {
            items = List<Map<String, dynamic>>.from(responseData['data']);
          });
          print('Items loaded: ${items.length}');
        } else if (responseData is List) {
          // In case the API returns a direct list without a 'data' wrapper
          setState(() {
            items = List<Map<String, dynamic>>.from(responseData);
          });
          print('Items loaded directly: ${items.length}');
        } else {
          print('Error: Unexpected data format: $responseData');
        }
      }
    } catch (e) {
      print("Error fetching items: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load items: $e')));
      }
    }
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cart.add(item);
      saveCart();
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item['name']} added to cart!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ItemsPage with ${items.length} items');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CartPage(cart: cart, token: widget.token),
                ),
              ).then(
                (_) => loadCart(),
              ); // Reload cart when returning from CartPage
            },
          ),
        ],
      ),
      body:
          items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['description'] ?? ''),
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
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => addToCart(item),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveCart(); // Save cart before logging out
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        label: const Text("Back to Login"),
        icon: const Icon(Icons.arrow_back),
      ),
    );
  }
}
