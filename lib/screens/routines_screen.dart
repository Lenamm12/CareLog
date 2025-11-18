import 'package:carelog/models/routine.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:carelog/database/database_helper.dart';

import '../l10n/app_localizations.dart';
import 'add_routine_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Routine> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      _loadRoutines();
    });
    _loadRoutines(); // Initial load
  }

  Future<void> _loadRoutines() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      final localRoutines = await DatabaseHelper.instance.getRoutines();
      if (mounted) {
        setState(() {
          _routines = localRoutines;
          _isLoading = false;
        });
      }
    } else {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('routines')
            .get();
        final firestoreRoutines =
            snapshot.docs.map((doc) => Routine.fromFirestore(doc)).toList();
        if (mounted) {
          setState(() {
            _routines = firestoreRoutines;
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

  void _navigateToAddRoutine([Routine? routine]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRoutineScreen(
          routine: routine,
          onRoutineSaved: _loadRoutines,
        ),
      ),
    );
  }

  void _updateRoutineLastDone(Routine routine, DateTime? lastDone) async {
    final user = _auth.currentUser;
    routine.lastDone = lastDone;
    if (user == null) {
      await DatabaseHelper.instance.updateRoutine(routine);
      _loadRoutines();
    } else {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('routines')
          .doc(routine.id)
          .update({'lastDone': lastDone});
      // We need to reload the routines to see the change
      _loadRoutines();
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myRoutines)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _routines.isEmpty
              ? Center(
                  child: Text(l10n.addRoutinePrompt),
                )
              : ListView.builder(
                  itemCount: _routines.length,
                  itemBuilder: (context, index) {
                    final routine = _routines[index];
                    final isDone = routine.lastDone != null &&
                        isSameDay(routine.lastDone!, DateTime.now());
                    return ListTile(
                      title: Text(routine.name),
                      trailing: Checkbox(
                        value: isDone,
                        onChanged: (value) {
                          _updateRoutineLastDone(
                              routine, value! ? DateTime.now() : null);
                        },
                      ),
                      onTap: () => _navigateToAddRoutine(routine),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRoutine',
        onPressed: () => _navigateToAddRoutine(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
