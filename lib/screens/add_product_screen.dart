import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _isEditing;
  String _name = '';
  String _brand = '';
  String _benefit = '';
  DateTime _purchaseDate = DateTime.now();
  String _price = '';
  DateTime _openingDate = DateTime.now();
  String _expiryPeriod = '6 months'; // Default value
  final int _customExpiryValue = 0;
  final String _customExpiryUnit = 'days';
  String _notes = '';

  final List<String> _expiryPeriods = [
    '6 months',
    '12 months',
    '24 months',
    '36 months',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;
    if (_isEditing) {
      _name = widget.product!.name;
      _brand = widget.product!.brand;
      _benefit = widget.product!.benefit;
      _purchaseDate = widget.product!.purchaseDate;
      _price = widget.product!.price.toString();
      _openingDate = widget.product!.openingDate;
      _expiryPeriod = widget.product!.expiryPeriod;
      _notes = widget.product!.notes;
      // For custom expiry, you might need to parse _expiryPeriod
    }
  }

  final List<String> _customExpiryUnits = ['days', 'months', 'years'];

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Calculate expiry date based on the selected period
      DateTime calculatedExpiryDate;
      if (_expiryPeriod == 'Custom') {
        // Assuming Product.calculateExpiryDate handles custom values
        calculatedExpiryDate = Product.calculateExpiryDate(
          _openingDate,
          '$_customExpiryValue $_customExpiryUnit',
        );
      } else {
        calculatedExpiryDate = Product.calculateExpiryDate(
          _openingDate,
          _expiryPeriod,
        );
      }

      if (_isEditing) {
        final updatedProduct = Product(
          id: widget.product!.id, // Use the existing ID
          name: _name,
          brand: _brand,
          benefit: _benefit,
          purchaseDate: _purchaseDate,
          price: double.tryParse(_price) ?? 0.0,
          openingDate: _openingDate,
          expiryPeriod: _expiryPeriod,
          expiryDate: calculatedExpiryDate,
          notes: _notes,
          type: '',
        );
        onUpdate(updatedProduct);
        Navigator.pop(context); // Go back after updating
      } else {
        final newProduct = Product(
          name: _name,
          brand: _brand,
          benefit: _benefit,
          purchaseDate: _purchaseDate,
          price: double.tryParse(_price) ?? 0.0,
          openingDate: _openingDate,
          expiryPeriod: _expiryPeriod,
          expiryDate: calculatedExpiryDate,
          notes: _notes,
          type: '',
        );

        _firestore.collection('products').doc(newProduct.id).set({
          'name': newProduct.name,
          'brand': newProduct.brand,
          'benefit': newProduct.benefit,
          'purchaseDate': Timestamp.fromDate(newProduct.purchaseDate),
          'price': newProduct.price,
          'openingDate': Timestamp.fromDate(newProduct.openingDate),
          'expiryDate': Timestamp.fromDate(newProduct.expiryDate),
          'notes': newProduct.notes,
          'type': newProduct.type,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Added const for performance
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
                initialValue: _name, // Pre-fill for editing
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Brand'),
                onSaved: (value) {
                  _brand = value ?? ''; // Use null-aware assignment
                },
                initialValue: _brand, // Pre-fill for editing
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Benefit'),
                onSaved: (value) {
                  _benefit = value ?? ''; // Use null-aware assignment
                },
                initialValue: _benefit, // Pre-fill for editing
              ),
              TextFormField(
                // Moved up for better flow
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) {
                  _price = value!;
                },
              ),
              ListTile(
                title: Text(
                  'Purchase Date: ${DateFormat('yyyy-MM-dd').format(_purchaseDate)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap:
                    () => _selectDate(context, _purchaseDate, (date) {
                      setState(() {
                        _purchaseDate = date;
                      });
                    }),
              ),
              ListTile(
                title: Text(
                  'Opening Date: ${DateFormat('yyyy-MM-dd').format(_openingDate)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap:
                    () => _selectDate(context, _openingDate, (date) {
                      setState(() {
                        _openingDate = date;
                      });
                    }),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Expiry Period'),
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
                onSaved: (value) {
                  _expiryPeriod = value ?? ''; // Use null-aware assignment
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) {
                  _notes = value ?? ''; // Use null-aware assignment
                },
                initialValue: _notes, // Pre-fill for editing
              ),
              if (_isEditing) // Show update and delete buttons in editing mode
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _saveProduct, // This now handles update
                    child: Text('Update Product'),
                  ),
                ),
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      onDelete(widget.product!.id);
                      Navigator.pop(context); // Go back after deleting
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Delete Product'),
                  ),
                ),
              if (!_isEditing)
                Padding(
                  // Show 'Add Product' button in adding mode
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text('Save Product'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onUpdate(Product updatedProduct) async {
    await _firestore
        .collection('products')
        .doc(updatedProduct.id)
        .update(updatedProduct.toMap());
    Navigator.pop(context);
  }

  void onDelete(String id) async {
    await _firestore.collection('products').doc(id).delete();
    Navigator.pop(context);
  }
}
