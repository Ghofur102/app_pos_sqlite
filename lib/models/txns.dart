class Txns {
  final int id;
  final int userId;
  final String createdAt;
  final int total;
  final String status;
  final double latitude;
  final double longitude;

  Txns({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.total,
    required this.status,
    required this.latitude,
    required this.longitude
  });

  factory Txns.fromMap(Map<String, dynamic> m) => Txns(id: m["id"], userId: m["user_id"], createdAt: m["created_at"], total: m["total"], status: m["status"], latitude: m["latitude"], longitude: m["longitude"]);
}