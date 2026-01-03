import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'crop_diagnostic.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        farm_size REAL,
        location TEXT,
        preferred_language TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    
    // Chats table
    await db.execute('''
      CREATE TABLE chats (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        message TEXT NOT NULL,
        message_type TEXT NOT NULL,
        is_sent INTEGER NOT NULL,
        image_url TEXT,
        voice_url TEXT,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Diagnosis table
    await db.execute('''
      CREATE TABLE diagnoses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        crop_type TEXT NOT NULL,
        image_url TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        severity TEXT NOT NULL,
        description TEXT,
        treatment TEXT,
        diagnosis_date TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Farm records table
    await db.execute('''
      CREATE TABLE farm_records (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        field_name TEXT NOT NULL,
        crop_type TEXT NOT NULL,
        planting_date TEXT,
        expected_harvest_date TEXT,
        actual_harvest_date TEXT,
        area REAL,
        yield REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Activities table
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        farm_record_id TEXT NOT NULL,
        activity_type TEXT NOT NULL,
        description TEXT,
        cost REAL,
        activity_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (farm_record_id) REFERENCES farm_records (id)
      )
    ''');
    
    // Market prices cache
    await db.execute('''
      CREATE TABLE market_prices (
        id TEXT PRIMARY KEY,
        crop_type TEXT NOT NULL,
        market_name TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');
    
    // Weather data cache
    await db.execute('''
      CREATE TABLE weather_data (
        id TEXT PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        temperature REAL,
        humidity REAL,
        rainfall REAL,
        wind_speed REAL,
        forecast_data TEXT,
        last_updated TEXT NOT NULL
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
  }
  
  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }
  
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }
  
  Future<int> delete(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
  
  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('chats');
    await db.delete('diagnoses');
    await db.delete('farm_records');
    await db.delete('activities');
    await db.delete('market_prices');
    await db.delete('weather_data');
  }
}
