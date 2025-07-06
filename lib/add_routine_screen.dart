import 'package:flutter/material.dart';
import 'routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'product.dart'; // Import the Product class
import 'product_selection_screen.dart'; // Import the new screen

class AddRoutineScreen extends StatefulWidget {
  final Routine? routine;

  // Make routine optional, null means adding, non-null means editing
  const AddRoutineScreen({super.key, this.routine});

  @override
  _AddRoutineScreenState createState() => _AddRoutineScreenState();
}

class _AddRoutineScreenState extends State<AddRoutineScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  late Routine currentRoutine; // Use late to initialize in initState

  @override
  void initState() {
    super.initState();
    // Initialize currentRoutine based on whether a routine was provided
    if (widget.routine != null) {
      currentRoutine = Routine(
        id: widget.routine!.id,
        name: widget.routine!.name,
        products: widget.routine!.products ?? [],
        frequency: widget.routine!.frequency,
        notes: widget.routine!.notes,
      );
    } else {
      currentRoutine = Routine(
        id: '', // Will be generated in Routine constructor if not provided
        name: '',
        products: [],
        frequency: 'Daily',
        notes: '',
      );
    }
  }

  String get _appBarTitle {
    return widget.routine == null ? 'Add New Routine' : 'Edit Routine';
  }

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'Custom'];

  void _saveRoutine() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = _auth.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to save a routine')),
        );
        return;
      }

      // Use the existing routine ID if editing, otherwise a new one will be generated
      final routineToSave = Routine(
        id: widget.routine?.id, // Pass the existing ID if available
        name: currentRoutine.name,
        products: currentRoutine.products,
        frequency: currentRoutine.frequency,
        notes: currentRoutine.notes,
      );

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('routines')
            .doc(routineToSave.id) // Use routineToSave.id
            .set(routineToSave.toMap()); // Use routineToSave.toMap()
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine saved successfully!')),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving routine: $e')));
      }
    }
  }

  void _selectProducts() async {
    final selectedProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductSelectionScreen(
              initialSelectedProducts: currentRoutine.products ?? [],
            ),
      ),
    );

    if (selectedProducts != null && selectedProducts is List<Product>) {
      setState(() {
        currentRoutine.products = selectedProducts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)), // Use the dynamic title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: currentRoutine.name, // Pre-populate for editing
                decoration: const InputDecoration(labelText: 'Routine Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a routine name';
                  }
                  return null;
                },
                onSaved: (value) {
                  currentRoutine.name = value!;
                },
              ),
              ListTile(
                title: const Text('Select Products'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectProducts, // Call the _selectProducts method
              ),
              // Display selected products
              if (currentRoutine.products != null &&
                  currentRoutine.products!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Selected Products:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentRoutine.products!.length,
                      itemBuilder: (context, index) {
                        final product = currentRoutine.products![index];
                        return ListTile(
                          leading:
                              product.imagePath != null
                                  ? Image.network(product.imagePath!)
                                  : null, // Display image if available
                          title: Text(product.name),
                        );
                      },
                    ),
                  ],
                ),
              DropdownButtonFormField<String>(
                value: currentRoutine.frequency, // Pre-populate for editing
                decoration: const InputDecoration(labelText: 'Frequency'),
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
                      currentRoutine.frequency = newValue;
                    });
                  }
                },
                onSaved: (value) {
                  currentRoutine.frequency = value!;
                },
              ),
              TextFormField(
                initialValue: currentRoutine.notes, // Pre-populate for editing
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
                onSaved: (value) {
                  currentRoutine.notes = value!;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ElevatedButton(
                  onPressed: _saveRoutine,
                  child: Text(
                    widget.routine == null ? 'Save Routine' : 'Update Routine',
                  ), // Button text based on mode
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
