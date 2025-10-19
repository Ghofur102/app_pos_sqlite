class Txns {
  final int id;
  final int userId;
  final String createdAt;
  final int total;

  Txns({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.total,
  });

  factory Txns.fromMap(Map<String, dynamic> m) => Txns(id: m["id"], userId: m["user_id"], createdAt: m["created_at"], total: m["total"]);
}