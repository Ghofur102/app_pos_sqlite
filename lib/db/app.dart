import "dart:async";
import "package:path/path.dart";
import "package:sqflite/sqflite.dart";

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _init();
    return _db!;
  }


  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "pos_app.db");
    // Always delete existing database file so tables and seed are recreated
    // Note: This makes the app start with a fresh DB each run.
    try {
      await deleteDatabase(path);
    } catch (e) {
      // ignore errors when deleting (e.g., file not exists)
    }

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

   Future<void> _seedDatabase(Database db) async {
    final List<Map<String, dynamic>> dummyItems = [
      {"name": "Nasi Goreng", "price": 15000, "category": "Makanan"},
      {"name": "Mie Goreng", "price": 12000, "category": "Makanan"},
      {"name": "Es Teh", "price": 3000, "category": "Minuman"},
      {"name": "Es Jeruk", "price": 5000, "category": "Minuman"},
    ];

    for (var element in dummyItems) {
      await db.insert("items", element);
    }

    final List<Map<String, dynamic>> adminUser = [
      {"full_name": "Admin", "username": "Admin", "email": "Admin@gmail.com", "password": "Admin", "role": "Admin"}
    ];

    for (var element in adminUser) {
      await db.insert("users", element);
    }
  }

  Future<void> _onUpgrade(Database database, int oldVersion, int newVersion) async {
    if(oldVersion < 5) {
      await _seedDatabase(database);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, full_name TEXT, username TEXT UNIQUE, email TEXT, password TEXT, role TEXT)");
    await db.execute(
        "CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE, price INTEGER, category TEXT)");
    await db.execute(
        "CREATE TABLE txns(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, created_at TEXT, total INTEGER, status TEXT, latitude DOUBLE, longitude DOUBLE)");
    await db.execute(
        "CREATE TABLE txn_items(id INTEGER PRIMARY KEY AUTOINCREMENT, txn_id INTEGER, item_id INTEGER, qty INTEGER, price INTEGER)");
    await _seedDatabase(db);
  }
}
