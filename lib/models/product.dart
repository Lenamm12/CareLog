import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Product {
  String? id;
  final String name;
  final String brand;
  final String type;
  final DateTime? purchaseDate;
  final double? price;
  final DateTime? openingDate;
  final String? expiryPeriod;
  final String? notes;
  final String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.brand,
    required this.type,
    this.purchaseDate,
    this.price,
    this.openingDate,
    this.expiryPeriod,
    this.notes,
    this.imagePath,
  }) {
    id ??= const Uuid().v4();
  }

  DateTime? get expiryDate {
    if (openingDate == null || expiryPeriod == null) {
      return null;
    }
    final months = int.tryParse(expiryPeriod!.split(' ').first) ?? 0;
    return DateTime(
      openingDate!.year,
      openingDate!.month + months,
      openingDate!.day,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      type: data['type'] ?? '',
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      price: (data['price'] as num?)?.toDouble(),
      openingDate: (data['openingDate'] as Timestamp?)?.toDate(),
      expiryPeriod: data['expiryPeriod'],
      notes: data['notes'],
      imagePath: data['imagePath'],
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String?,
      name: map['name'] as String,
      brand: map['brand'] as String,
      type: map['type'] as String,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchaseDate'] as int)
          : null,
      price: map['price'] as double?,
      openingDate: map['openingDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['openingDate'] as int)
          : null,
      expiryPeriod: map['expiryPeriod'] as String?,
      notes: map['notes'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'purchaseDate': purchaseDate?.millisecondsSinceEpoch,
      'price': price,
      'openingDate': openingDate?.millisecondsSinceEpoch,
      'expiryPeriod': expiryPeriod,
      'notes': notes,
      'imagePath': imagePath,
    };
  }
}
