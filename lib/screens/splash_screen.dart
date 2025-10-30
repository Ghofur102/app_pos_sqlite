import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 Future<bool> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
 }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: FutureBuilder(
          future: _checkLoginStatus(), 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.blueAccent,);
            }

            if(snapshot.hasData) {
              final bool isLoggedIn = snapshot.data!;
              if(isLoggedIn) {
                return _buildMenuButton(context);
              } else {
                _buildAuthButton(context);
              }
            }

            return _buildAuthButton(context);
          }
        )
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.storefront, size: 100, color: Colors.white),
        const SizedBox(height: 20),
        const Text(
          "Selamat Datang di POS App",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Silakan masuk ke halaman utama",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            if(prefs.getString("role") == "Admin") {
               Navigator.pushNamedAndRemoveUntil(
                context, "/list-menu-admin", (route) => false);
            } else {
               Navigator.pushNamedAndRemoveUntil(
                context, "/menu", (route) => false);
            }
          },
          child: const Text("Menu Utama"),
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.storefront, size: 100, color: Colors.white),
        const SizedBox(height: 20),
        const Text(
          "Selamat Datang di POS App",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Silakan masuk atau daftar untuk melanjutkan",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
          child: const Text("Masuk"),
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, "/register");
          },
          child: const Text("Daftar"),
        ),
      ],
    );
  }
}
