import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:carelog/models/routine.dart'; // Import Routine model
import 'package:carelog/database/database_helper.dart'; // Import DatabaseHelper

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Routine>> _routinesByDay = {};

  User? get currentUser => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Fetch routines when the screen loads
    _fetchRoutines();
  }

  void _fetchRoutines() async {
    if (currentUser == null) {
      final routines = await DatabaseHelper.instance.getRoutines();
      _populateRoutinesByDay(routines);
    } else {
      _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('routines')
          .snapshots()
          .listen((snapshot) {
        final routines =
            snapshot.docs.map((doc) => Routine.fromFirestore(doc)).toList();
        _populateRoutinesByDay(routines);
      });
    }
  }

  void _populateRoutinesByDay(List<Routine> routines) {
    final newRoutinesByDay = <DateTime, List<Routine>>{};
    for (var routine in routines) {
      // Get the start date of the calendar view
      final firstDay = DateTime.utc(2020, 1, 1);
      // Get the last date of the calendar view
      final lastDay = DateTime.utc(2030, 12, 31);

      for (var day = firstDay; day.isBefore(lastDay); day = day.add(const Duration(days: 1))) {
        if (_shouldShowRoutineOnDay(routine, day)) {
          final date = DateTime.utc(day.year, day.month, day.day);
          if (newRoutinesByDay[date] == null) {
            newRoutinesByDay[date] = [];
          }
          newRoutinesByDay[date]!.add(routine);
        }
      }
    }
    setState(() {
      _routinesByDay = newRoutinesByDay;
    });
  }

  bool _shouldShowRoutineOnDay(Routine routine, DateTime day) {
    switch (routine.frequency) {
      case 'Daily':
        return true;
      case 'Weekly':
        return day.weekday == DateTime.monday; // Or any other logic
      case 'Monthly':
        return day.day == 1; // Or any other logic
      default:
        return false;
    }
  }

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
            eventLoader: (day) {
              return _routinesByDay[DateTime.utc(day.year, day.month, day.day)] ?? [];
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildUpcomingRoutinesList()),
        ],
      ),
    );
  }

  Widget _buildUpcomingRoutinesList() {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to see upcoming routines.'),
      );
    }

    final selectedDayRoutines = _routinesByDay[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];

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
        );
      },
    );
  }
}
