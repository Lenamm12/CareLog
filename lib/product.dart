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
    required this.notes, required DateTime expiryDate,
 this.imagePath, // Make imagePath optional in constructor
  }) :
 id = id ?? const Uuid().v4(), // Generate ID if not provided
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

  // You can add other methods here, e.g., for serialization/deserialization if needed.
}
