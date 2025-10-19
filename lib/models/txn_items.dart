class TxnItems {
  final int id;
  final int txnId;
  final int itemId;
  final int qty;
  final int price;

  TxnItems({
    required this.id,
    required this.txnId,
    required this.itemId,
    required this.qty,
    required this.price,
  });

  factory TxnItems.fromMap(Map<String, dynamic> m) => TxnItems(id: m["id"], txnId: m["txn_id"], itemId: m["item_id"], qty: m["qty"], price: m["price"]);
}