import 'product.dart'; // Assuming your Product class is in product.dart
import 'package:uuid/uuid.dart';

class Routine {
  final String id;
  String name;
  List<Product> products;
  String frequency;
  String notes;

  Routine({
    required this.name,
    required this.products,
    required this.frequency,
    required this.notes,
  }) : id = const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'products':
          products.map((product) => product.id).toList(), // Store product IDs
      'frequency': frequency,
      'notes': notes,
    };
  }
}
