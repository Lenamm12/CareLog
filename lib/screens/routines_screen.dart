import 'package:carelog/models/routine.dart';
import 'package:flutter/material.dart';
import 'add_routine_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  _RoutinesScreenState createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Routines')),
        body: const Center(
          child: Text('Please log in to view your routines.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Routines')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('routines')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final routines = snapshot.data!.docs.map((doc) {
            return Routine.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: routines.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(routines[index].name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRoutineScreen(routine: routines[index])),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
}
