import 'package:carelog/models/routine.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _loadLocalRoutines();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('My Routines')),
      body:
          user == null ? _buildLocalRoutines() : _buildFirestoreRoutines(user),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addRoutine',
        onPressed: () {
          Navigator.pushNamed(context, '/add_routine').then((_) {
            if (user == null) {
              _loadLocalRoutines();
            }
          });
        },
        tooltip: 'Add New Routine',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLocalRoutines() {
    if (_localRoutines.isEmpty) {
      return const Center(child: Text('2. And then create a routine'));
    }
    return ListView.builder(
      itemCount: _localRoutines.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_localRoutines[index].name),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/add_routine',
              arguments: _localRoutines[index],
            ).then((_) => _loadLocalRoutines());
          },
        );
      },
    );
  }

  Widget _buildFirestoreRoutines(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('routines')
              .snapshots(),
      builder: (context, firestoreSnapshot) {
        if (firestoreSnapshot.hasError) {
          return Center(child: Text('Error: ${firestoreSnapshot.error}'));
        }

        if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
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
                Navigator.pushNamed(
                  context,
                  '/add_routine',
                  arguments: routine,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _loadLocalRoutines() async {
    final routines = await DatabaseHelper.instance.getRoutines();
    if (mounted) {
      setState(() {
        _localRoutines = routines;
      });
    }
  }
}
