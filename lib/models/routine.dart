import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'product.dart';

class Routine {
  String id;
  String name;
  List<Product>? products;
  String frequency;
  String? notes;
  DateTime? lastDone; // Add lastDone field

  Routine({
    String? id,
    required this.name,
    this.products,
    required this.frequency,
    this.notes,
    this.lastDone,
  }) : id = id ?? const Uuid().v4();

  factory Routine.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Routine(
      id: doc.id,
      name: data['name'] ?? '',
      products:
          (data['products'] as List<dynamic>?)
              ?.map(
                (productData) =>
                    Product.fromMap(productData as Map<String, dynamic>),
              )
              .toList(),
      frequency: data['frequency'] ?? 'Daily',
      notes: data['notes'],
      lastDone: (data['lastDone'] as Timestamp?)?.toDate(),
    );
  }

  factory Routine.fromMap(Map<String, dynamic> map, List<Product> products) {
    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      products: products,
      frequency: map['frequency'] as String,
      notes: map['notes'] as String?,
      lastDone:
          map['lastDone'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastDone'] as int)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'productIds': products?.map((p) => p.id).toList() ?? [],
      'frequency': frequency,
      'notes': notes,
      'lastDone': lastDone?.millisecondsSinceEpoch,
    };
  }
}
