import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Dummy data for morning and evening products
  final List<String> _morningProducts = [
    'Cleanser (Morning)',
    'Toner (Morning)',
    'Serum (Morning)',
  ];

  final List<String> _eveningProducts = [
    'Cleanser (Evening)',
    'Retinol (Evening)',
    'Moisturizer (Evening)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Morning Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _morningProducts.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(_morningProducts[index]));
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Evening Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _eveningProducts.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(_eveningProducts[index]));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
