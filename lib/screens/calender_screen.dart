import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carelog/models/routine.dart'; // Import Routine model

int getDaysInMonth(int year, int month) {
  if (month == DateTime.february) {
    return isLeapYear(year) ? 29 : 28;
  } else if (month == DateTime.april ||
      month == DateTime.june ||
      month == DateTime.september ||
      month == DateTime.november) {
    return 30;
  } else {
    return 31;
  }
}

// Helper function to check for leap year
bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<Routine>> _routinesByDay = {};

  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildUpcomingRoutinesList()),
        ],
      ),
    );
  }

  Widget _buildUpcomingRoutinesList() {
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view your routines.'));
    }

    // If no date is selected, show a message
    if (_selectedDay == null) {
      return const Center(child: Text('Select a day to see upcoming routines.'));
    }

    // ... (login and selected day checks)

    return StreamBuilder<QuerySnapshot>(
      // This StreamBuilder fetches all routines
      stream:
          _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('routines')
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error fetching routines: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

 if (snapshot.hasData && snapshot.data != null) {
        }

        // Populate _routinesByDay with fetched routines
        snapshot.data!.docs.forEach((doc) {
          final routine = Routine.fromFirestore(doc);
          // Here's where you determine the scheduled dates for each routine
          // and add the routine to the _routinesByDay map for those dates.
          // This is the part that needs the frequency logic.

          // Example (basic daily frequency):
          if (routine.frequency == 'Daily') {
            // Assuming you have a start date for the routine
            // For simplicity, let's just add it to the current month for now
            final now = DateTime.now();
            final daysInMonth = getDaysInMonth(now.year, now.month);
            for (int i = 1; i <= daysInMonth; i++) {
              final day = DateTime(now.year, now.month, i);
              if (_routinesByDay[day] == null) {
                _routinesByDay[day] = [];
              }
              _routinesByDay[day]!.add(routine);
            }
          }
          // You would add similar logic for Weekly, Monthly, Custom frequencies
        });

        // Now, after populating _routinesByDay, filter for the selected day
        final selectedDayRoutines = _routinesByDay[_selectedDay] ?? [];

        if (selectedDayRoutines.isEmpty) {
          return const Center(
            child: Text('No routines scheduled for this day.'),
          );
        }

        return ListView.builder(
          itemCount: selectedDayRoutines.length,
          itemBuilder: (context, index) {
            final routine = selectedDayRoutines[index];
            return ListTile(
              title: Text(routine.name),
              // Add more details here
            );
          },
        );
      },
    );
  }
}
