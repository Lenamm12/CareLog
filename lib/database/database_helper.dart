import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/routine.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  static DatabaseHelper get instance => _instance;


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'carelog_app.db');
    return await openDatabase(path, version: 4, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        brand TEXT,
        type TEXT,
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
        notes TEXT,
        completedDates TEXT,
        weekDay INTEGER,
        dayOfMonth INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE routines ADD COLUMN lastDone INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE routines ADD COLUMN completedDates TEXT');
    }
    if (oldVersion < 4) {
      // To remove a column, we have to create a new table, copy the data, and then drop the old table.
      await db.execute('''
          CREATE TABLE routines_new(
            id TEXT PRIMARY KEY,
            name TEXT,
            frequency TEXT,
            productIds TEXT,
            notes TEXT,
            completedDates TEXT,
            weekDay INTEGER,
            dayOfMonth INTEGER
          )
      ''');
      await db.execute('''
          INSERT INTO routines_new(id, name, frequency, productIds, notes, completedDates)
          SELECT id, name, frequency, productIds, notes, completedDates FROM routines
      ''');
      await db.execute('DROP TABLE routines');
      await db.execute('ALTER TABLE routines_new RENAME TO routines');
    }
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
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

  Future<int> insertRoutine(Routine routine) async {
    final db = await database;
    final Map<String, dynamic> row = {
      'id': routine.id,
      'name': routine.name,
      'frequency': routine.frequency,
      'productIds': jsonEncode(routine.products?.map((p) => p.id).toList() ?? []),
      'notes': routine.notes,
      'completedDates': jsonEncode(routine.completedDates.map((d) => d.toIso8601String()).toList()),
      'weekDay': routine.weekDay,
      'dayOfMonth': routine.dayOfMonth,
    };
    return await db.insert(
      'routines',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> routineMaps = await db.query('routines');
    final List<Routine> routines = [];

    for (var routineMap in routineMaps) {
      final productIdsString = routineMap['productIds'] as String?;
      List<Product> products = [];
      if (productIdsString != null) {
        final productIds = List<String>.from(jsonDecode(productIdsString));
        for (var productId in productIds) {
          final productMaps = await db.query('products', where: 'id = ?', whereArgs: [productId]);
          if (productMaps.isNotEmpty) {
            products.add(Product.fromMap(productMaps.first));
          }
        }
      }
      routines.add(Routine.fromMap(routineMap, products));
    }
    return routines;
  }


  Future<int> updateRoutine(Routine routine) async {
    final db = await database;
    final Map<String, dynamic> row = {
      'id': routine.id,
      'name': routine.name,
      'frequency': routine.frequency,
      'productIds': jsonEncode(routine.products?.map((p) => p.id).toList() ?? []),
      'notes': routine.notes,
      'completedDates': jsonEncode(routine.completedDates.map((d) => d.toIso8601String()).toList()),
      'weekDay': routine.weekDay,
      'dayOfMonth': routine.dayOfMonth,
    };
    return await db.update(
      'routines',
      row,
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  Future<int> deleteRoutine(String id) async {
    final db = await database;
    return await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }
}
