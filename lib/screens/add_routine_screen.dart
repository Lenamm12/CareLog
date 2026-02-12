import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart'; // Import the Product class
import '../database/database_helper.dart'; // Import the DatabaseHelper
import 'product_selection_screen.dart'; // Import the new screen

class AddRoutineScreen extends StatefulWidget {
  final Routine? routine;
  final VoidCallback? onRoutineSaved;
  const AddRoutineScreen({super.key, this.routine, this.onRoutineSaved});

  @override
  State<AddRoutineScreen> createState() => _AddRoutineScreenState();
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

  String _appBarTitle(AppLocalizations l10n) {
    return widget.routine == null ? l10n.addNewRoutine : l10n.editRoutine;
  }

  void _saveRoutine() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = _auth.currentUser;

      // Use the existing routine ID if editing, otherwise a new one will be generated
      final routineToSave = Routine(
        id: widget.routine?.id, // Pass the existing ID if available
        name: currentRoutine.name,
        products: currentRoutine.products,
        frequency: currentRoutine.frequency,
        notes: currentRoutine.notes,
      );

      if (user == null) {
        // Handle the case where the user is not logged in (local save)
        if (widget.routine == null) {
          // Adding a new routine
          onSaveLocal(routineToSave);
        } else {
          // Updating an existing routine
          onUpdateLocal(routineToSave);
        }
      } else {
        // User is logged in (Firestore save)

        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('routines')
              .doc(routineToSave.id) // Use routineToSave.id
              .set(routineToSave.toMap()); // Use routineToSave.toMap()
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.routineSavedSuccess)));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.errorSavingRoutine}: $e')),
          );
        }
      }
      if (widget.onRoutineSaved != null) {
        widget.onRoutineSaved!();
      }
      Navigator.pop(context); // Go back after saving
    }
  }

  void _deleteRoutine() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.routine == null) return;

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('routines')
            .doc(widget.routine!.id)
            .delete();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.routineDeletedSuccess)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorDeletingRoutine}: $e')),
        );
      }
    } else {
      // Handle local deletion
      await DatabaseHelper.instance.deleteRoutine(widget.routine!.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineSavedLocally)));
    }
    if (widget.onRoutineSaved != null) {
      widget.onRoutineSaved!();
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
          title: Text(l10n.deleteRoutine),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(l10n.deleteRoutineConfirmation)],
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
                _deleteRoutine();
                Navigator.of(context).pop(); // Pop the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _selectProducts() async {
    final selectedProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductSelectionScreen(initialSelectedProducts: currentRoutine.products ?? []),
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
    final l10n = AppLocalizations.of(context)!;
    final Map<String, String> frequencyMap = {
      'Daily': l10n.daily,
      'DailyMorning': l10n.dailyMorning,
      'DailyEvening': l10n.dailyEvening,
      'Weekly': l10n.weekly,
      'Monthly': l10n.monthly,
    };
    final Map<int, String> weekdays = {
      1 : l10n.monday,
      2: l10n.tuesday,
      3: l10n.wednesday,
      4: l10n.thursday,
      5: l10n.friday,
      6: l10n.saturday,
      7: l10n.sunday
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(l10n)),
        actions: [
          if (widget.routine != null)
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
              TextFormField(
                initialValue: currentRoutine.name, // Pre-populate for editing
                decoration: InputDecoration(labelText: l10n.routineName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterRoutineName;
                  }
                  return null;
                },
                onSaved: (value) {
                  currentRoutine.name = value!;
                },
              ),
              ListTile(
                title: Text(l10n.selectProducts),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _selectProducts, // Call the _selectProducts method
              ),
              // Display selected products
              if (currentRoutine.products != null &&
                  currentRoutine.products!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        l10n.selectedProducts,
                        style: const TextStyle(
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
                          leading: product.imagePath != null
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
                decoration: InputDecoration(labelText: l10n.frequency),
                items: frequencyMap.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
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
              const SizedBox(height: 16),
              if(currentRoutine.frequency == 'Weekly')
              DropdownButtonFormField(items: weekdays.entries.map((weekday){
                return DropdownMenuItem<int>(
                  value: weekday.key,
                  child: Text(weekday.value.toString()),
                );
              }).toList(), onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentRoutine.weekDay = newValue;
                  });
                }
              }),
              const SizedBox(height: 16),
              if(currentRoutine.frequency == 'Monthly')
              DropdownButtonFormField(items:
              List.generate(31, (index) => (index + 1)).map((day){
                return DropdownMenuItem<int>(
                  value: day,
                  child: Text(day.toString()),
                );
              }).toList(), onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentRoutine.dayOfMonth = newValue;
                  });
                }
              }),
              TextFormField(
                initialValue: currentRoutine.notes, // Pre-populate for editing
                decoration: InputDecoration(labelText: l10n.notes),
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
                    widget.routine == null
                        ? l10n.saveRoutine
                        : l10n.updateRoutine,
                  ), // Button text based on mode
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onSaveLocal(Routine routineToSave) async {
    final l10n = AppLocalizations.of(context)!;
    await DatabaseHelper.instance.insertRoutine(routineToSave);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.routineSavedLocally)));
  }

  void onUpdateLocal(Routine routineToSave) async {
    final l10n = AppLocalizations.of(context)!;
    // Ensure the routineToSave has a valid ID for updating
    if (routineToSave.id.isNotEmpty) {
      await DatabaseHelper.instance.updateRoutine(routineToSave);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.routineUpdatedLocally)));
    }
  }
}
