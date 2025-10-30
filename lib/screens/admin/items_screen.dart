import 'package:app_pos_sqlite/components/header.dart';
import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/item.dart';
import 'package:app_pos_sqlite/screens/admin/add_item_screen.dart';
import 'package:app_pos_sqlite/screens/admin/edit_item_screen.dart';
import 'package:app_pos_sqlite/screens/admin/list_transactions_screen.dart';
import 'package:app_pos_sqlite/utils/format_uang.dart';
import 'package:flutter/material.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItemListScreen();
  }
}

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<ItemListScreen> createState() => _ItemListScreenPage();
}

class _ItemListScreenPage extends State<ItemListScreen> {
  late Future<List<Item?>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = Repo.instance.getAllItem();
  }

  Future<void> _refreshItemList() async {
    setState(() {
      futureItems = Repo.instance.getAllItem();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: FutureBuilder(
          future: futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text(
                      "Gagal memuat item: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshItemList,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Tidak ada pengguna yang ditemukan.");
            } else {
              List<Item?> items = snapshot.data!;
              return buildUserListView(items);
            }
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "1",
            onPressed: () async {
              final bool? result = await Navigator.of(
                context,
              ).push(MaterialPageRoute(
                  builder: (context) => const AddItemScreen()));

              if (result == true) {
                _refreshItemList();
              }
            },
            tooltip: 'Tambah Menu Baru',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 20),
          FloatingActionButton(
            heroTag: "2",
            onPressed: () async {
              final bool? result = await Navigator.of(
                context,
              ).push(MaterialPageRoute(
                  builder: (context) => const ListTransactionsScreen()));

              if (result == true) {
                _refreshItemList();
              }
            },
            tooltip: 'List Transaksi',
            child: const Icon(Icons.list_alt),
          ),
        ],
      ),
    );
  }

  Widget buildUserListView(List<Item?> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        Item? item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                "${item!.name} | ${item.category}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                "Harga: ${formatUang(item.price)}",
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueGrey),
                    onPressed: () async {
                      final bool? result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditItemScreen(item: item),
                        ),
                      );
                      if (result == true) {
                        _refreshItemList();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Berhasil mengedit untuk item ${item.name}",
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      _showDeleteDialog(item);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: Text("Apakah anda yakin ingin menghapus ${item.name}"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  Repo.instance.deleteItem(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Item ${item.name} berhasil dihapus!"),
                    ),
                  );
                  _refreshItemList();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus user: $e")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
