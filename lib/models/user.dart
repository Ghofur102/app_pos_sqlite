class User {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String password;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> m) => User(id: m["id"], fullName: m["full_name"], username: m["username"], email: m["email"], password: m["password"]);
}


