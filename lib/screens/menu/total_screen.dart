import 'package:app_pos_sqlite/components/card_menu.dart';
import 'package:app_pos_sqlite/components/header.dart';
import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/item.dart';
import 'package:app_pos_sqlite/utils/format_uang.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class TotalScreen extends StatefulWidget {
  const TotalScreen({super.key});

  @override
  State<TotalScreen> createState() => _TotalScreenState();
}

class _TotalScreenState extends State<TotalScreen> {
  late Future<List<Item?>> _futureItems;
  late List<Item?> _loadedItems;
  late Map<int, int> pesanan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    pesanan = ModalRoute.of(context)!.settings.arguments as Map<int, int>;
    final ids = pesanan.keys.toList();
    _futureItems = Repo.instance.getSomeItem(ids);
  }

  int _calculateTotal(List<Item?> items) {
    return items.fold(0, (int previousValue, item) {
      if (item == null) {
        return previousValue;
      }
      final int quantity = pesanan[item.id] ?? 0;
      return previousValue + (item.price * quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: const Header(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Pembelian Makanan & Minuman",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder(
                future: _futureItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Tidak ada data",
                            style: TextStyle(color: Colors.white)));
                  }
                  final items = snapshot.data!;
                  _loadedItems = items;
                  final total = _calculateTotal(items);
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              if (item == null) {
                                return const SizedBox.shrink();
                              }
                              return CardMenu(
                                item: item,
                                onAdd: null,
                                onRemove: null,
                                totalPesanan: pesanan[item.id] ?? 0,
                                onTap: () {},
                              );
                            }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Total: ${formatUang(total)}",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/menu");
                },
                child: Icon(Icons.navigate_before),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () {
                  // memanggil _loadedItems berisi Map<id, jumlah-pembelian>
                  final items = _loadedItems;

                  if (items.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Tidak ada item!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }

                  // variabel untuk data detail pesanan dan total pembelian
                  Map<String, dynamic> pesananDetail = {};
                  int totalHargaPesanan = 0;

                  // memasukkan semua data dari items ke detail pesanan dan total pembelian
                  for (var i = 0; i < items.length; i++) {
                    // variabel item untuk menampung data items[i]
                    final item = items[i];

                    // jika item tidak ada datanya (null) maka continue, lanjut ke iterasi berikutnya tanpa eksekusi kode dibawahnya
                    if (item == null) {
                      continue;
                    }

                    // variabel untuk menentukan jumlah pembelian dan total pembelian pada suatu item
                    final quantity = pesanan[item.id] ?? 0;
                    final subtotal = item.price * quantity;

                    // memasukkan data detail suatu pesanan ke map pesananDetail
                    pesananDetail["pesanan-${i + 1}"] = {
                      "item_id": item.id,
                      "name": item.name,
                      "price": item.price,
                      "quantity": quantity,
                      "subtotal": subtotal,
                      "category": item.category,
                    };

                    // totalHargaPesanan ditambah dengan subtotal dari tiap pesanan
                    totalHargaPesanan += subtotal;
                  }

                  final dataTransaksi = {
                    "pesanan": pesananDetail,
                    "total": totalHargaPesanan,
                  };
                  Navigator.pushNamed(context, "/transaksi",
                      arguments: dataTransaksi);
                },
                child: Icon(Icons.navigate_next),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
