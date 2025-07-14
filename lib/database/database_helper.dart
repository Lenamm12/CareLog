import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/routine.dart';
import '../models/product.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'carelog_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        brand TEXT,
        type TEXT,
        benefit TEXT,
        purchaseDate INTEGER,
        price REAL,
        openingDate INTEGER,
        expiryPeriod TEXT,
        expiryDate INTEGER,
        imagePath TEXT,
        notes TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE routines(
        id TEXT PRIMARY KEY,
        name TEXT,
 frequency TEXT,
 productIds TEXT,
        notes TEXT
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final map = {
      'id': product.id,
      'name': product.name,
      'brand': product.brand,
      'type': product.type,
      'benefit': product.benefit,
      'purchaseDate': product.purchaseDate.millisecondsSinceEpoch,
      'price': product.price,
      'openingDate': product.openingDate.millisecondsSinceEpoch,
      'expiryPeriod': product.expiryPeriod,
      'expiryDate': product.expiryDate.millisecondsSinceEpoch,
      'imagePath': product.imagePath,
      'notes': product.notes,
    };
    return await db.insert('products', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<int> updateProduct(Product product) async {
    final db = await database;
    final map = {
      'id': product.id,
      'name': product.name,
      'brand': product.brand,
      'type': product.type,
      'benefit': product.benefit,
      'purchaseDate': product.purchaseDate.millisecondsSinceEpoch,
      'price': product.price,
      'openingDate': product.openingDate.millisecondsSinceEpoch,
      'expiryPeriod': product.expiryPeriod,
      'expiryDate': product.expiryDate.millisecondsSinceEpoch,
      'imagePath': product.imagePath,
      'notes': product.notes,
    };
    return await db.update('products', map, where: 'id = ?', whereArgs: [product.id]);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  Future<int> deleteProduct(String id) async {
    Database db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Placeholder methods for routines
  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    final map = {
      'id': routine.id,
      'name': routine.name,
      'frequency': routine.frequency,
      'productIds': jsonEncode(routine.products?.map((p) => p.id).toList() ?? []),
      'notes': routine.notes,
    };
    return await db.insert('routines', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');
    return List.generate(maps.length, (i) {
      final routineMap = maps[i];
      final productIdsString = routineMap['productIds'] as String?;
      List<String> productIds = [];
      if (productIdsString != null) {
        productIds = List<String>.from(jsonDecode(productIdsString));
      }
      return Routine.fromMap(routineMap, productIds: productIds);
    });
  }

  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    final map = {
      'id': routine.id,
      'name': routine.name,
      'frequency': routine.frequency,
      'productIds': jsonEncode(routine.products?.map((p) => p.id).toList() ?? []),
      'notes': routine.notes,
    };
    return await db.update('routines', map, where: 'id = ?', whereArgs: [routine.id]);
  }

  Future<int> deleteRoutine(String id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  // You can add methods for updating data as well
  static DatabaseHelper get instance => _instance;
}