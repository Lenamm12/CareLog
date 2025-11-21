import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'product.dart';

class Routine {
  String id;
  String name;
  List<Product>? products;
  String frequency;
  String? notes;
  List<DateTime> completedDates;
  int weekDay = 0;
  int dayOfMonth = 0;


  Routine({
    String? id,
    required this.name,
    this.products,
    required this.frequency,
    this.notes,
    List<DateTime>? completedDates,
    int? weekDay,
    int? dayOfMonth,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [];

  DateTime? get lastDone {
    if (completedDates.isEmpty) {
      return null;
    }
    var sortedDates = List<DateTime>.from(completedDates);
    sortedDates.sort((a, b) => b.compareTo(a));
    return sortedDates.first;
  }

  factory Routine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      products: (data['products'] as List<dynamic>?)
          ?.map(
            (productData) =>
                Product.fromMap(productData as Map<String, dynamic>),
          )
          .toList(),
      frequency: data['frequency'] ?? 'Daily',
      notes: data['notes'],
      completedDates: (data['completedDates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList(),
    );
  }

  factory Routine.fromMap(Map<String, dynamic> map, List<Product> products) {
    List<DateTime>? dates;
    if (map['completedDates'] != null &&
        (map['completedDates'] as String).isNotEmpty) {
      final decoded =
          jsonDecode(map['completedDates'] as String) as List<dynamic>;
      dates = decoded.map((date) => DateTime.parse(date as String)).toList();
    }

    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      products: products,
      frequency: map['frequency'] as String,
      notes: map['notes'] as String?,
      completedDates: dates ?? [],
      weekDay: map['weekDay'] ,
      dayOfMonth: map['dayOfMonth'] ,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'productIds': products?.map((p) => p.id).toList() ?? [],
      'frequency': frequency,
      'notes': notes,
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'weekDay': weekDay,
      'dayOfMonth': dayOfMonth,
    };
  }
}
