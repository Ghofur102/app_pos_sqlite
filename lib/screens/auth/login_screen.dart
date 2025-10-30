import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "../../db/repository.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();

  Future<void> _login() async {
    try {
      final user = await Repo.instance.login(_u.text, _p.text);
      if(!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      await prefs.setInt("idUser", user!.id);
      await prefs.setString("role", user.role);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil login!"), backgroundColor: Colors.greenAccent,));
      if(user.role == "Admin") {
        Navigator.pushNamedAndRemoveUntil(context, "/list-menu-admin", (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/menu", (route) => false);
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.redAccent,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_pin, size: 60, color: Colors.blueAccent),
            TextField(controller: _u, decoration: const InputDecoration(labelText: "Username"),),
            TextField(controller: _p, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _login, 
                  child: const Text("Login", style: TextStyle(color: Colors.white))
                ),
                SizedBox(width: 20),
                ElevatedButton(onPressed: () {
                  Navigator.pushNamed(context, "/register");
                }, child: const Text("Register"))
              ],
            ),
          ],
        ),
      ),
    );
  }
}