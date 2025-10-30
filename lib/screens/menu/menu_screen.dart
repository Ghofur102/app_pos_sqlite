import 'package:app_pos_sqlite/components/card_menu.dart';
import 'package:app_pos_sqlite/components/header.dart';
import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/item.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Map<int, int> _pesanan = {};
  late Future<List<Item?>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = Repo.instance.getAllItem();
  }

  void _tambahPesanan(Item item) {
    setState(() {
      _pesanan[item.id] = (_pesanan[item.id] ?? 0) + 1;
    });
  }

  void _kurangiPesanan(Item item) {
    setState(() {
      if (_pesanan.containsKey(item.id) && _pesanan[item.id]! > 0) {
        _pesanan[item.id] = _pesanan[item.id]! - 1;
        if (_pesanan[item.id] == 0) {
          _pesanan.remove(item.id);
        }
      }
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
            "Menu Makanan & Minuman",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Container(
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/nota-pembelian");
              },
              icon: Icon(Icons.list_alt),
              tooltip: "Transaksi",
            ),
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
                  return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return CardMenu(
                          item: item!,
                          onAdd: () => _tambahPesanan(item),
                          onRemove: () => _kurangiPesanan(item),
                          totalPesanan: _pesanan[item.id] ?? 0,
                          onTap: () {},
                        );
                      });
                }),
          ),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/total-pesanan",
                  arguments: _pesanan);
            },
            child: Icon(Icons.navigate_next),
          ),
        ],
      ),
    );
  }
}
