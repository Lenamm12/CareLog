import 'package:carelog/models/routine.dart';
import 'package:flutter/material.dart';
import 'add_routine_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:carelog/database/database_helper.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Routine> _localRoutines = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routines')),
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = authSnapshot.data;

          if (user == null) {
            // User is signed out, display local data
            _loadLocalRoutines(); // Load local data when signed out initially or on state change
            return _localRoutines.isEmpty
                ? const Center(child: Text('No local routines found.'))
                : ListView.builder(
                  itemCount: _localRoutines.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_localRoutines[index].name),
                      onTap: () {
                        // Implement local routine editing
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddRoutineScreen(
                                  routine: _localRoutines[index],
                                ),
                          ),
                        );
                      },
                    );
                  },
                );
          } else {
            // User is signed in, display Firestore data
            return StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('routines')
                      .snapshots(),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${firestoreSnapshot.error}'),
                  );
                }

                if (firestoreSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final routines =
                    firestoreSnapshot.data!.docs.map((doc) {
                      return Routine.fromFirestore(doc);
                    }).toList();

                return ListView.builder(
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return ListTile(
                      title: Text(routine.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AddRoutineScreen(routine: routine),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // User is signed in, add to Firestore
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRoutineScreen()),
          );
        },
        tooltip: 'Add New Routine', // Added tooltip for accessibility
        child: const Icon(Icons.add), // Added const for performance
      ),
    );
  }

  Future<void> _loadLocalRoutines() async {
    final routines = await DatabaseHelper.instance.getRoutines();
    setState(() {
      _localRoutines = routines;
    });
  }
}
