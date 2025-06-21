import 'product.dart'; // Assuming your Product class is in product.dart

class Routine {
  String name;
  List<Product> products;
  String frequency;
  String notes;

  Routine({
    required this.name,
    required this.products,
    required this.frequency,
    required this.notes,
  });
}