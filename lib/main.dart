import "dart:io";
import 'package:app_pos_sqlite/screens/admin/items_screen.dart';
import 'package:app_pos_sqlite/screens/auth/login_screen.dart';
import 'package:app_pos_sqlite/screens/auth/register_screen.dart';
import 'package:app_pos_sqlite/screens/menu/menu_screen.dart';
import 'package:app_pos_sqlite/screens/menu/total_screen.dart';
import 'package:app_pos_sqlite/screens/transactions/receipt_screen.dart';
import 'package:app_pos_sqlite/screens/transactions/transactions_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // --- LANGKAH DEBUGGING ---
    // Print ini akan muncul di konsol jika blok ini dieksekusi
    print("===== Inisialisasi Database FFI untuk Desktop... =====");
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    print("===== Inisialisasi Database FFI Selesai. =====");
  } else {
    // Print ini akan muncul jika kondisi di atas tidak terpenuhi
    print(
        "===== Menggunakan Database Factory Standar (Mobile atau Web). =====");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "POS Demo (SQLite)",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/menu': (context) => const MenuScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/total-pesanan': (context) => const TotalScreen(),
        '/transaksi': (context) => const TransactionsScreen(),
        "/nota-pembelian": (context) => const MyListTransactionsScreen(),
        "/list-menu-admin": (context) => const ItemsScreen(),
      },
    );
  }
}
