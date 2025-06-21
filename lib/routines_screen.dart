import 'package:flutter/material.dart';
import 'add_routine_screen.dart';

class RoutinesScreen extends StatelessWidget {
  // Dummy data for now
  final List<String> routineNames = [
    'Morning Skincare',
    'Evening Skincare',
    'Weekly Hair Mask',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Routines')),
      body: ListView.builder(
        itemCount: routineNames.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(routineNames[index]),
            // TODO: Implement onTap to view routine details
            onTap: () {
              // Navigate to routine detail screen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRoutineScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Routine',
      ),
    );
  }
}
