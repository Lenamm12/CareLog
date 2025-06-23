import 'package:flutter/material.dart';
import 'product.dart';
import 'routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoutineScreen extends StatefulWidget {
  const AddRoutineScreen({super.key});

  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final _formKey = GlobalKey<FormState>();

  String _routineName = '';
  final List<Product> _selectedProducts =
      []; // Placeholder for selected products
  String _frequency = 'Daily'; // Default frequency
  String _notes = '';

  // Dummy list of products for selection (replace with actual data later)
  final List<Product> _availableProducts = [
    Product(
      name: 'Cleanser',
      brand: 'Brand A',
      benefit: 'Cleansing',
      purchaseDate: DateTime.now(),
      price: 15.0,
      openingDate: DateTime.now(),
      expiryPeriod: '12 months',
      notes: '',
      expiryDate: DateTime.now().add(Duration(days: 365)),
      type: 'product',
    ),
    Product(
      name: 'Serum',
      brand: 'Brand B',
      benefit: 'Hydration',
      purchaseDate: DateTime.now(),
      price: 30.0,
      openingDate: DateTime.now(),
      expiryPeriod: '6 months',
      notes: '',
      expiryDate: DateTime.now().add(Duration(days: 180)),
      type: 'product',
    ),
    // Add more dummy products
  ];

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'Custom'];

  void _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newRoutine = Routine(
        name: _routineName,
        products:
            _selectedProducts, // Assuming _selectedProducts contains Product objects
        frequency: _frequency,
        notes: _notes,
      );

      try {
        await FirebaseFirestore.instance
            .collection('routines')
            .doc(newRoutine.id)
            .set(newRoutine.toMap());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine saved successfully!')),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving routine: $e')));
      }

      // TODO: Implement saving the routine to your data storage
      // Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Routine')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Routine Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a routine name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _routineName = value!;
                },
              ),
              // Placeholder for product selection
              ListTile(
                title: Text('Select Products'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Implement navigation to a product selection screen
                  print('Navigate to product selection');
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Frequency'),
                value: _frequency,
                items:
                    _frequencies.map((String frequency) {
                      return DropdownMenuItem<String>(
                        value: frequency,
                        child: Text(frequency),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _frequency = newValue;
                    });
                  }
                },
                onSaved: (value) {
                  _frequency = value!;
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
                  onPressed: _saveRoutine,
                  child: Text('Save Routine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
