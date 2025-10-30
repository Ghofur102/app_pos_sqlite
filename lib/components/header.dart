import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.setInt("idUser", -1);
    await prefs.setString("role", "");
    if (!context.mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    await navigator.pushNamedAndRemoveUntil("/", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueAccent,
      automaticallyImplyLeading: false,
      elevation: 100,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.storefront,
                size: 35,
                color: Colors.white,
              ),
              const Text("APP POS",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size.zero,
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: const Text(
                "Splash Screen",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: Size.zero,
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () => _logout(context),
              child: const Text(
                "Log Out",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
