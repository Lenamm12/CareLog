import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Product {
  final String id; // Unique ID for each product
  String name;
  String brand;
  String type;
  String benefit;
  DateTime purchaseDate;
  double price;
  DateTime openingDate;
  String expiryPeriod;
  DateTime expiryDate;
  String? imagePath; // Nullable field for image path
  String notes;

  Product({
    String? id, // Make id optional in constructor
    required this.name,
    required this.brand,
    required this.type,
    required this.benefit,
    required this.purchaseDate,
    required this.price,
    required this.openingDate,
    required this.expiryPeriod, // Keep this as it is used for calculation
    required this.notes,
    required DateTime expiryDate,
    this.imagePath, // Make imagePath optional in constructor
  }) : id = id ?? const Uuid().v4(), // Generate ID if not provided
       expiryDate = calculateExpiryDate(openingDate, expiryPeriod);

  static DateTime calculateExpiryDate(
    DateTime openingDate,
    String expiryPeriod,
  ) {
    int daysToAdd = 0;
    int monthsToAdd = 0;
    int yearsToAdd = 0;

    final parts = expiryPeriod.toLowerCase().split(' ');
    if (parts.length == 2) {
      final value = int.tryParse(parts[0]);
      if (value != null) {
        final unit = parts[1];
        if (unit.contains('day')) {
          daysToAdd = value;
        } else if (unit.contains('month')) {
          monthsToAdd = value;
        } else if (unit.contains('year')) {
          yearsToAdd = value;
        }
      }
    } else {
      // Handle cases like "6 months", "12 months", etc. from the initial dropdown
      try {
        monthsToAdd = int.parse(
          expiryPeriod.toLowerCase().replaceAll(' months', '').trim(),
        );
      } catch (e) {
        // Handle parsing errors, maybe default to a certain period or throw an error
        print('Error parsing expiry period: $e');
      }
    }

    DateTime calculatedDate = openingDate.add(Duration(days: daysToAdd));
    calculatedDate = DateTime(
      calculatedDate.year + yearsToAdd,
      calculatedDate.month + monthsToAdd,
      calculatedDate.day,
    );
    return calculatedDate;
  }

  static fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id, // Use the document ID as the product ID
      name: data['name'] ?? '', // Use null-aware operator for safety
      brand: data['brand'] ?? '',
      type: data['type'] ?? '',
      benefit: data['benefit'] ?? '',
      purchaseDate:
          (data['purchaseDate'] as Timestamp)
              .toDate(), // Convert Timestamp to DateTime
      price: (data['price'] ?? 0.0).toDouble(), // Ensure it's a double
      openingDate: (data['openingDate'] as Timestamp).toDate(),
      expiryPeriod: data['expiryPeriod'] ?? '',
      notes: data['notes'] ?? '',
      imagePath: data['imagePath'], // This can be null
      expiryDate: (data['expiryDate'] as Timestamp).toDate(),
    );
  }

  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      type: map['type'],
      benefit: map['benefit'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      price: map['price'],
      openingDate: DateTime.fromMillisecondsSinceEpoch(map['openingDate']),
      expiryPeriod: map['expiryPeriod'],
      notes: map['notes'],
      imagePath: map['imagePath'],
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'benefit': benefit,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'price': price,
      'openingDate': openingDate.millisecondsSinceEpoch,
      'expiryPeriod': expiryPeriod,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  // You can add other methods here, e.g., for serialization/deserialization if needed.
}
