class Item {
  final int id;
  final String name;
  final int price;
  final String category;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  factory Item.fromMap(Map<String, dynamic> m) => Item(id: m["id"], name: m["name"], price: m["price"], category: m["category"]);
}