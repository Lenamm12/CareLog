import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // You might need to add the intl dependency to your pubspec.yaml
import 'product.dart';

class AddProductScreen extends StatefulWidget {
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
  int _customExpiryValue = 0;
  String _customExpiryUnit = 'days';
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

      // Here you would typically save the product data
      // For now, just print the data
      print('Name: $_name');
      print('Brand: $_brand');
      print('Benefit: $_benefit');
      print('Purchase Date: ${_purchaseDate.toIso8601String()}');
      print('Price: $_price');
      print('Opening Date: ${_openingDate.toIso8601String()}');
      print('Expiry Period: $_expiryPeriod');
      if (_expiryPeriod == 'Custom') {
        print('Custom Expiry: $_customExpiryValue $_customExpiryUnit');
        print('Notes: $_notes');

        // TODO: Implement saving the product to your data storage
        // Navigator.pop(context); // Go back after saving
      }
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) {
                  _price = value!;
                },
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
