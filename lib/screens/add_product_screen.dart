import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Brand'),
                onSaved: (value) {
                  _brand = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Benefit'),
                onSaved: (value) {
                  _benefit = value!;
                },
              ),
              TextFormField(
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
                  _expiryPeriod = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) {
                  _notes = value!;
                },
              ),
              Padding(
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
}
