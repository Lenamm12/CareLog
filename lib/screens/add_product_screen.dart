import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late bool _isEditing;
  String _name = '';
  String _brand = '';
  String _type = '';
  DateTime _purchaseDate = DateTime.now();
  String _price = '';
  DateTime _openingDate = DateTime.now();
  String _expiryPeriod = '6 months';
  String _notes = '';
  File? _image;

  List<Product> _generalProducts = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  final List<String> _expiryPeriods = [
    '6 months',
    '12 months',
    '24 months',
    '36 months',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;
    if (_isEditing) {
      _name = widget.product!.name;
      _brand = widget.product!.brand;
      _type = widget.product!.type;
      _purchaseDate = widget.product!.purchaseDate ?? DateTime.now();
      _price = widget.product!.price?.toString() ?? '';
      _openingDate = widget.product!.openingDate ?? DateTime.now();
      _expiryPeriod = widget.product!.expiryPeriod ?? '6 months';
      _notes = widget.product!.notes ?? '';
      if (widget.product!.imagePath != null) {
        _image = File(widget.product!.imagePath!);
      }
    }
    _nameController.text = _name;
    _brandController.text = _brand;
    _typeController.text = _type;
    _fetchGeneralProducts();
  }

  Future<void> _fetchGeneralProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      setState(() {
        _generalProducts =
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = _auth.currentUser;
      final imagePath = _image?.path;

      if (user == null) {
        final newProduct = Product(
          name: _name,
          brand: _brand,
          type: _type,
          purchaseDate: _purchaseDate,
          price: double.tryParse(_price) ?? 0.0,
          openingDate: _openingDate,
          expiryPeriod: _expiryPeriod,
          notes: _notes,
          imagePath: imagePath,
        );
        if (_isEditing) {
          await DatabaseHelper.instance.updateProduct(newProduct);
        } else {
          await DatabaseHelper.instance.insertProduct(newProduct);
        }
      } else {
        // Check if the product exists in the general list
        QuerySnapshot querySnapshot =
            await _firestore
                .collection('products')
                .where('name', isEqualTo: _name)
                .where('brand', isEqualTo: _brand)
                .get();

        if (querySnapshot.docs.isEmpty) {
          // Add to general product list if it doesn't exist
          await _firestore.collection('products').add({
            'name': _name,
            'brand': _brand,
            'type': _type,
          });
        }

        if (_isEditing) {
          final updatedProduct = Product(
            id: widget.product!.id,
            name: _name,
            brand: _brand,
            type: _type,
            purchaseDate: _purchaseDate,
            price: double.tryParse(_price) ?? 0.0,
            openingDate: _openingDate,
            expiryPeriod: _expiryPeriod,
            notes: _notes,
            imagePath: imagePath,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('products')
              .doc(widget.product!.id)
              .update(updatedProduct.toMap());
        } else {
          final newProduct = Product(
            name: _name,
            brand: _brand,
            type: _type,
            purchaseDate: _purchaseDate,
            price: double.tryParse(_price) ?? 0.0,
            openingDate: _openingDate,
            expiryPeriod: _expiryPeriod,
            notes: _notes,
            imagePath: imagePath,
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('products')
              .add(newProduct.toMap());
        }
      }
      Navigator.pop(context);
    }
  }

  void _deleteProduct() async {
    if (!_isEditing) return;

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc(widget.product!.id)
          .delete();
    } else {
      await DatabaseHelper.instance.deleteProduct(widget.product!.id!);
    }
    Navigator.pop(context); // Pop the edit screen
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteProduct),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(l10n.deleteProductConfirmation)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.delete),
              onPressed: () {
                _deleteProduct();
                Navigator.of(context).pop(); // Pop the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProduct : l10n.addProduct),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmationDialog,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child:
                      _image == null
                          ? const Icon(Icons.add_a_photo, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              Autocomplete<Product>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Product>.empty();
                  }
                  return _generalProducts.where((Product option) {
                    return option.name.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                displayStringForOption:
                    (Product option) =>
                        '${option.name} - ${option.brand} (${option.type})',
                onSelected: (Product selection) {
                  setState(() {
                    _name = selection.name;
                    _brand = selection.brand;
                    _type = selection.type;
                    _nameController.text = _name;
                    _brandController.text = _brand;
                    _typeController.text = _type;
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  _nameController.addListener(() {
                    textEditingController.value = _nameController.value;
                  });
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(labelText: l10n.productName),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterName;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  );
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(labelText: l10n.brand),
                onSaved: (value) {
                  _brand = value ?? '';
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(labelText: l10n.type),
                onSaved: (value) {
                  _type = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.price),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initialValue: _price,
                onSaved: (value) {
                  _price = value!;
                },
              ),
              ListTile(
                title: Text(
                  '${l10n.purchaseDate}: ${DateFormat('yyyy-MM-dd').format(_purchaseDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap:
                    () => _selectDate(context, _purchaseDate, (date) {
                      setState(() {
                        _purchaseDate = date;
                      });
                    }),
              ),
              ListTile(
                title: Text(
                  '${l10n.openingDate}: ${DateFormat('yyyy-MM-dd').format(_openingDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap:
                    () => _selectDate(context, _openingDate, (date) {
                      setState(() {
                        _openingDate = date;
                      });
                    }),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.expiryPeriod),
                value: _expiryPeriod,
                items:
                    _expiryPeriods.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _expiryPeriod = newValue;
                    });
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 3,
                initialValue: _notes,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(_isEditing ? l10n.update : l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
