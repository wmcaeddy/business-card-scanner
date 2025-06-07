import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/business_card.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _tableName = 'business_cards';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'business_cards.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        company TEXT,
        jobTitle TEXT,
        phone TEXT,
        email TEXT,
        website TEXT,
        address TEXT,
        notes TEXT,
        imagePath TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  Future<String> insertBusinessCard(BusinessCard card) async {
    final db = await database;

    await db.insert(
      _tableName,
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return card.id;
  }

  Future<List<BusinessCard>> getAllBusinessCards() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return BusinessCard.fromMap(maps[i]);
    });
  }

  Future<BusinessCard?> getBusinessCard(String id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BusinessCard.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateBusinessCard(BusinessCard card) async {
    final db = await database;

    await db.update(
      _tableName,
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteBusinessCard(String id) async {
    final db = await database;

    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BusinessCard>> searchBusinessCards(String query) async {
    final db = await database;
    final lowercaseQuery = '%${query.toLowerCase()}%';

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '''
        LOWER(name) LIKE ? OR 
        LOWER(company) LIKE ? OR 
        LOWER(email) LIKE ? OR 
        LOWER(phone) LIKE ? OR
        LOWER(jobTitle) LIKE ?
      ''',
      whereArgs: [
        lowercaseQuery,
        lowercaseQuery,
        lowercaseQuery,
        lowercaseQuery,
        lowercaseQuery
      ],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return BusinessCard.fromMap(maps[i]);
    });
  }

  Future<int> getBusinessCardCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteAllBusinessCards() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // For debugging purposes
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'business_cards.db');
  }
}
