import 'package:carelog/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import 'add_product_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  final List<Product> initialSelectedProducts;

  const ProductSelectionScreen({
    super.key,
    this.initialSelectedProducts = const [],
  });

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> _userProducts = [];
  List<Product> _selectedProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProducts = List.from(widget.initialSelectedProducts);
    _fetchUserProducts();
  }

  Future<void> _fetchUserProducts() async {
    final user = _auth.currentUser;
    if (user == null) {
      try {
        final localProducts = await DatabaseHelper.instance.getProducts();
        setState(() {
          _userProducts = localProducts;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Error fetching local products: $e';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .get();

      setState(() {
        _userProducts =
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching products: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleProductSelection(Product product) {
    setState(() {
      if (_selectedProducts.any((p) => p.id == product.id)) {
        _selectedProducts.removeWhere((p) => p.id == product.id);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedProducts);
  }

  void _navigateToAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    // Refresh the product list after adding a new one
    _fetchUserProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToAddProduct),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSelection),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _userProducts.length,
                  itemBuilder: (context, index) {
                    final product = _userProducts[index];
                    final isSelected = _selectedProducts.any((p) => p.id == product.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        _toggleProductSelection(product);
                      },
                      title: Text(product.name),
                      subtitle: Text(product.brand),
                    );
                  },
                ),
    );
  }
}
