import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart'; // Assuming your Product class is in product.dart
import 'package:uuid/uuid.dart';

class Routine {
  final String id;
  String name;
  List<Product>? products;
  String frequency;
  String notes;
  DateTime? lastDone;

  Routine({
    String? id,
    required this.name,
    this.products,
    required this.frequency,
    required this.notes,
    this.lastDone,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'products':
          products?.map((product) => product.id).toList(), // Store product IDs
      'frequency': frequency,
      'notes': notes,
      'lastDone': lastDone,
    };
  }

  factory Routine.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      // products will be fetched separately based on IDs
      products: null, // Initialize products as null or an empty list
      frequency: data['frequency'] ?? '',
      notes: data['notes'] ?? '',
      lastDone: data['lastDone'] != null ? (data['lastDone'] as Timestamp).toDate() : null,
    );
  }

  static Routine fromMap(
    Map<String, dynamic> routineMap, {
    required List<String> productIds,
  }) {
    return Routine(
      id: routineMap['id'],
      name: routineMap['name'] ?? '',
      // For local storage, we only store product IDs in the Routine object.
      // The actual Product objects will need to be fetched separately if needed.
      products: null,
      frequency: routineMap['frequency'] ?? '',
      notes: routineMap['notes'] ?? '',
      lastDone: routineMap['lastDone'] != null ? DateTime.fromMillisecondsSinceEpoch(routineMap['lastDone']) : null,
    );
  }
}
