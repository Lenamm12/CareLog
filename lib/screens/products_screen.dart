import 'dart:io';
import 'package:carelog/models/product.dart';
import 'package:flutter/material.dart';
import 'package:carelog/database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_localizations.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      _loadProducts();
    });
    _loadProducts(); // Initial load
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      final localProducts = await DatabaseHelper.instance.getProducts();
      setState(() {
        _products = localProducts;
        _isLoading = false;
      });
    } else {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .get();
        final firestoreProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
        setState(() {
          _products = firestoreProducts;
          _isLoading = false;
        });
      } catch (e) {
        // Handle error
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAddProduct([Product? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          product: product,
          onProductSaved: _loadProducts,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProducts)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(
                  child: Text(l10n.addProductsPrompt),
                )
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      leading: product.imagePath != null && product.imagePath!.isNotEmpty
                          ? (product.imagePath!.startsWith('http')
                              ? Image.network(product.imagePath!)
                              : Image.file(File(product.imagePath!)))
                          : null,
                      title: Text(product.name),
                      subtitle: Text('${product.brand} - ${product.type}'),
                      onTap: () => _navigateToAddProduct(product),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProduct',
        onPressed: () => _navigateToAddProduct(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
