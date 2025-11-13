import 'dart:io';
import 'package:carelog/models/product.dart';
import 'package:flutter/material.dart';
import 'package:carelog/database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _localProducts = [];

  @override
  void initState() {
    super.initState();
    _loadLocalProducts(); // Load local products initially
  }

  // User? get currentUser => _auth.currentUser; // We'll use the StreamBuilder's data

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, authSnapshot) {
        final user = authSnapshot.data;

        return Scaffold(
          appBar: AppBar(title: const Text('My Products')),
          body:
              user == null
                  ? _localProducts.isEmpty &&
                          authSnapshot.connectionState ==
                              ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : _localProducts.isEmpty
                      ? const Center(
                        child: Text('1. Start by adding some products'),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: _localProducts.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading:
                                        _localProducts[index].imagePath !=
                                                    null &&
                                                _localProducts[index]
                                                    .imagePath!
                                                    .isNotEmpty
                                            ? Image.file(
                                              File(
                                                _localProducts[index]
                                                    .imagePath!,
                                              ),
                                            )
                                            : null,
                                    title: Text(
                                      _localProducts[index].name,
                                    ), // Assuming imagePath is a URL for Firestore
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add_product',
                                        arguments: _localProducts[index],
                                      ); // Pass the tapped product for editing
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                  : StreamBuilder<QuerySnapshot>(
                    stream:
                        _firestore
                            .collection('users')
                            .doc(user.uid)
                            .collection('products')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final products =
                          snapshot.data!.docs.map((doc) {
                            return Product.fromFirestore(doc);
                          }).toList();

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading:
                                        products[index].imagePath != null
                                            ? Image.network(
                                              products[index].imagePath!,
                                            ) // Assuming imagePath is a URL for Firestore
                                            : null, // Handle no image case
                                    title: Text(
                                      products[index].name,
                                    ), // Assuming imagePath is a URL for Firestore
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/add_product',
                                        arguments: products[index],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'addProduct',
            onPressed: () {
              Navigator.pushNamed(context, '/add_product');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Future<void> _loadLocalProducts() async {
    final products = await DatabaseHelper.instance.getProducts();
    setState(() {
      _localProducts = products;
    });
  }
}
