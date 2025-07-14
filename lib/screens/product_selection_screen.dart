import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart'; // Assuming your Product class is in product.dart

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

  List<Product> _allProducts = [];
  List<Product> _selectedProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedProducts = List.from(
      widget.initialSelectedProducts,
    ); // Initialize with passed selected products
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _error = 'Please log in to select products.';
        _isLoading = false;
      });
      return;
    }

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('products')
              .get();

      setState(() {
        _allProducts =
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList()
                as List<Product>;
        // Ensure selected products are present in allProducts, helpful if initialSelectedProducts contained outdated data
        _selectedProducts.retainWhere(
          (selected) => _allProducts.any((all) => all.id == selected.id),
        );
        // Add any initial selected products that were not in _allProducts (shouldn't happen with correct data flow, but as a safeguard)
        for (var initial in widget.initialSelectedProducts) {
          if (!_selectedProducts.any((selected) => selected.id == initial.id) &&
              _allProducts.any((all) => all.id == initial.id)) {
            _selectedProducts.add(
              _allProducts.firstWhere((all) => all.id == initial.id),
            );
          }
        }

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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Product item = _selectedProducts.removeAt(oldIndex);
      _selectedProducts.insert(newIndex, item);
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedProducts);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Products')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Products')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    // Filter products to show only selected ones first, then unselected
    final List<Product> displayedProducts = [
      ..._selectedProducts,
      ..._allProducts.where(
        (product) =>
            !_selectedProducts.any((selected) => selected.id == product.id),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Products'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSelection),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: displayedProducts.length,
        itemBuilder: (context, index) {
          final product = displayedProducts[index];
          final isSelected = _selectedProducts.any((p) => p.id == product.id);
          return ListTile(
            key: ValueKey(
              product.id,
            ), // Key is required for ReorderableListView
            leading: Checkbox(
              value: isSelected,
              onChanged: (bool? value) {
                _toggleProductSelection(product);
              },
            ),
            title: Text(product.name),
            // Add more product details if needed
          );
        },
        onReorder: _onReorder,
      ),
    );
  }
}
