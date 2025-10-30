import 'package:app_pos_sqlite/models/item.dart';
import 'package:app_pos_sqlite/models/txns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import 'app.dart';

class Repo {
  // Singleton pattern untuk memastikan hanya ada satu instance dari Repo
  Repo._();
  static final Repo instance = Repo._();

  // Getter untuk mendapatkan instance database dari AppDatabase
  Future<Database> get _db async => AppDatabase.instance.database;

  
  // Menyimpan user baru ke dalam database.
  // Melempar exception jika username sudah ada.
  Future<int?> register(
      String fullName, String username, String email, String password) async {
    if (fullName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      throw Exception("Semua kolom wajib diisi!");
    }

    final db = await _db;

    final data = {
      "full_name": fullName,
      "username": username,
      "email": email,
      "password": password,
      "role": "user"
    };

    try {
      // conflictAlgorithm .fail akan melempar error jika username (UNIQUE) sudah ada
      final newUser = await db.insert("users", data,
          conflictAlgorithm: ConflictAlgorithm.fail);
      return newUser;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception("Username sudah digunakan!");
      } else {
        throw Exception("Gagal mendaftar, terjadi kesalahan pada database: $e");
      }
    } catch (e) {
      throw Exception("Gagal mendaftar, terjadi kesalahan: $e");
    }
  }

  // Memverifikasi username dan password untuk login.
  // Mengembalikan objek User jika berhasil, dan null jika gagal.
  Future<User?> login(String username, String password) async {
    try {
      if(username.isEmpty || username.isEmpty) {
        throw Exception("Username dan password wajib diisi!");
      }
      final db = await _db;
      final result = await db.query(
        "users",
        where: "username = ? AND password = ?",
        whereArgs: [username, password],
        limit: 1,
      );

      if (result.isNotEmpty) {
        // konversi data user login menjadi factory constructor
        return User.fromMap(result.first);
      } else {
        throw Exception("Username atau password salah!");
      }
    } catch (e) {
      print(e);
      throw Exception("Gagal login, terjadi kesalahan: $e");
    }
  }

  Future<List<Item?>> getAllItem() async {
    try {
      final db = await _db;
      final result = await db.query("items");
      if (result.isNotEmpty) {
        return result.map((itemMap) => Item.fromMap(itemMap)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Gagal mengambil data, terjadi kesalahan: $e");
    }
  }

  Future<List<Txns?>> getAllTransactions() async {
    try {
      final db = await _db;
      final result = await db.query("txns");
      if (result.isNotEmpty) {
        return result.map((itemMap) => Txns.fromMap(itemMap)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Gagal mengambil data, terjadi kesalahan: $e");
    }
  }

  Future<List<Item?>> getSomeItem(List<int> items) async {
    try {
      final db = await _db;
      final result = await db.query(
        "items",
        where: "id IN (${List.filled(items.length, "?").join(',')})",
        whereArgs: items,
      );
      return result.map((itemMap) => Item.fromMap(itemMap)).toList();
    } catch (e) {
      throw Exception("Gagal mengambil data, terjadi kesalahan: $e");
    }
  }

  Future<int?> addItem(String name, String price, String category) async {
    if(name.isEmpty || price.isEmpty || category.isEmpty) {
      throw Exception("Semua inputan harus diisi!");
    }

    int harga = int.parse(price);

    final db = await _db;

    final data = {
      "name": name,
      "price": harga,
      "category": category,
    };
     try {
      // conflictAlgorithm .fail akan melempar error jika username (UNIQUE) sudah ada
      final newItem = await db.insert("items", data,
          conflictAlgorithm: ConflictAlgorithm.fail);
      return newItem;
    } on DatabaseException catch (e) {
      throw Exception("Gagal menambahkan, terjadi kesalahan pada database: $e");
    } catch (e) {
      throw Exception("Gagal menambahkan, terjadi kesalahan: $e");
    }
  }

  Future<int> updateItem(int id, String name, String price, String category) async {
    if(name.isEmpty || price == 0 || category.isEmpty) {
      throw Exception("Semua inputan harus diisi!");
    }
    final db = await _db;

    int harga = int.parse(price);

    final data = {
      "name": name,
      "price": harga,
      "category": category,
    };
     try {
      // conflictAlgorithm .fail akan melempar error jika username (UNIQUE) sudah ada
      final updatedItem = await db.update("items", data, where: 'id = ?', whereArgs: [id]);
      return updatedItem;
    } on DatabaseException catch (e) {
      throw Exception("Gagal mengupdate, terjadi kesalahan pada database: $e");
    } catch (e) {
      throw Exception("Gagal mengupdate, terjadi kesalahan: $e");
    }
  }

  Future<int> deleteItem(int id) async {
    final db = await _db;
    try {
      // conflictAlgorithm .fail akan melempar error jika username (UNIQUE) sudah ada
      final updatedItem = await db.delete("items", where: 'id = ?', whereArgs: [id]);
      return updatedItem;
    } on DatabaseException catch (e) {
      throw Exception("Gagal menghapus, terjadi kesalahan pada database: $e");
    } catch (e) {
      throw Exception("Gagal menghapus, terjadi kesalahan: $e");
    }
  }

  Future<void> saveTransaction(int? userId, int total, double? latitude, double? longitude, List<Map<String, dynamic>> items) async {
   final db = await _db;
   final now = DateTime.now().toIso8601String();
   await db.transaction((txn) async {
    // 1️⃣ Simpan transaksi utama
    final txnId = await txn.insert("txns", {
      "user_id": userId,
      "created_at": now,
      "total": total,
      "status": "belum disetujui",
      "latitude": latitude,
      "longitude": longitude
      });

    // 2️⃣ Simpan item-item transaksi
    for (var item in items) {
      await txn.insert("txn_items", {
        "txn_id": txnId,
        "item_id": item["item_id"],
        "qty": item["quantity"],
        "price": item["price"],});
    }});
  }

  Future<int> approvedTransaction(Txns transaction) async {
    final db = await _db;
    final data = {
      "id": transaction.id,
      "user_id": transaction.userId,
      "total": transaction.total,
      "created_at": transaction.createdAt,
      "status": "disetujui"
    };
    return await db.update("txns", data, where: "id = ?", whereArgs: [transaction.id]);
  }

  Future<List<Txns>> getMyTransactions() async {
    try {
      final db = await _db;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("idUser");
      final result = await db.query("txns", where: 'user_id == ?', whereArgs: [userId]);
      if (result.isNotEmpty) {
        return result.map((itemMap) => Txns.fromMap(itemMap)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Gagal mengambil data, terjadi kesalahan: $e");
    }
  }


}
