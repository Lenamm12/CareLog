import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';

class ProductSelectionScreen extends StatefulWidget {
  final List<Product> initialSelectedProducts;

  const ProductSelectionScreen(
      {super.key, required this.initialSelectedProducts});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _allProducts = [];
  final List<Product> _selectedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedProducts.addAll(widget.initialSelectedProducts);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final user = _auth.currentUser;
    if (user == null) {
      final localProducts = await DatabaseHelper.instance.getProducts();
      if (mounted) {
        setState(() {
          _allProducts = localProducts;
          _isLoading = false;
        });
      }
    } else {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .get();
        final firestoreProducts =
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        if (mounted) {
          setState(() {
            _allProducts = firestoreProducts;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _onProductSelected(Product product, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedProducts.add(product);
      } else {
        _selectedProducts.removeWhere((p) => p.id == product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectProducts),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _selectedProducts),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allProducts.length,
              itemBuilder: (context, index) {
                final product = _allProducts[index];
                final isSelected = _selectedProducts.any((p) => p.id == product.id);
                return CheckboxListTile(
                  title: Text(product.name),
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _onProductSelected(product, value);
                    }
                  },
                );
              },
            ),
    );
  }
}
