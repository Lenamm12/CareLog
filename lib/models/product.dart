import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Product {
  String id; // Unique ID for each product
  String name;
  String brand;
  String type;
  String benefit;
  DateTime? purchaseDate;
  double? price;
  DateTime? openingDate;
  String? expiryPeriod;
  DateTime? expiryDate;
  String? imagePath; // Nullable field for image path
  String? notes;

  Product({
    String? id,
    required this.name,
    required this.brand,
    this.type = '',
    required this.benefit,
    this.purchaseDate,
    this.price,
    this.openingDate,
    this.expiryPeriod,
    this.expiryDate,
    this.notes,
    this.imagePath,
  }) : id = id ?? const Uuid().v4() {
    if (openingDate != null && expiryPeriod != null) {
      expiryDate = calculateExpiryDate(openingDate!, expiryPeriod!);
    }
  }

  static DateTime calculateExpiryDate(
    DateTime openingDate,
    String expiryPeriod,
  ) {
    int monthsToAdd = 0;
    final parts = expiryPeriod.toLowerCase().split(' ');
    if (parts.length == 2) {
      final value = int.tryParse(parts[0]);
      if (value != null) {
        if (parts[1].contains('month')) {
          monthsToAdd = value;
        } else if (parts[1].contains('year')) {
          monthsToAdd = value * 12;
        }
      }
    }

    return DateTime(
      openingDate.year,
      openingDate.month + monthsToAdd,
      openingDate.day,
    );
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      benefit: data['benefit'] ?? '',
      type: data['type'] ?? '',
      purchaseDate:
          data['purchaseDate'] != null
              ? (data['purchaseDate'] as Timestamp).toDate()
              : null,
      price: (data['price'] ?? 0.0).toDouble(),
      openingDate:
          data['openingDate'] != null
              ? (data['openingDate'] as Timestamp).toDate()
              : null,
      expiryPeriod: data['expiryPeriod'],
      expiryDate:
          data['expiryDate'] != null
              ? (data['expiryDate'] as Timestamp).toDate()
              : null,
      notes: data['notes'],
      imagePath: data['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'benefit': benefit,
      'type': type,
      'purchaseDate': purchaseDate,
      'price': price,
      'openingDate': openingDate,
      'expiryPeriod': expiryPeriod,
      'expiryDate': expiryDate,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      benefit: map['benefit'],
      type: map['type'],
      purchaseDate: map['purchaseDate'],
      price: map['price'],
      openingDate: map['openingDate'],
      expiryPeriod: map['expiryPeriod'],
      expiryDate: map['expiryDate'],
      notes: map['notes'],
      imagePath: map['imagePath'],
    );
  }
}
