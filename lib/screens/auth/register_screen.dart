import "package:flutter/material.dart";
import "../../db/repository.dart";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _u = TextEditingController();
  final _f = TextEditingController();
  final _e = TextEditingController();
  final _p = TextEditingController();

  Future<void> _register() async {
    try {
      final user = await Repo.instance.register(_f.text, _u.text, _e.text, _p.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Berhasil mendaftar! $user"),
          backgroundColor: Colors.greenAccent));
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll("Exception: ", "")),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 60, color: Colors.blueAccent),
            TextField(
                controller: _f,
                decoration: const InputDecoration(labelText: "Full Name")),
            TextField(
                controller: _u,
                decoration: const InputDecoration(labelText: "Username")),
            TextField(
                controller: _e,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _p,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _register,
                    child: const Text("Register", style: TextStyle(color: Colors.white)
                    )
                ),
                SizedBox(width: 20),
                ElevatedButton(onPressed: () {
                  Navigator.pushNamed(context, "/login");
                }, child: const Text("Login")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
