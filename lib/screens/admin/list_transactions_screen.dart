import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/txns.dart';
import 'package:app_pos_sqlite/screens/admin/items_screen.dart';
import 'package:app_pos_sqlite/utils/format_uang.dart';
import 'package:flutter/material.dart';

class ListTransactionsScreen extends StatelessWidget {
  const ListTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TransactionsListScreen(),
    );
  }
}

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  late Future<List<Txns?>> futureTransactions;

  @override
  void initState() {
    super.initState();
    futureTransactions = Repo.instance.getAllTransactions();
  }

  Future<void> _refreshTransactionsList() async {
    setState(() {
      futureTransactions = Repo.instance.getAllTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Transaksi (Read)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactionsList,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: futureTransactions,
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
                      "Gagal memuat transaksi: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _refreshTransactionsList,
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("Tidak ada transaksi yang ditemukan.");
            } else {
              List<Txns?> items = snapshot.data!;
              return buildUserListView(items);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(
              MaterialPageRoute(builder: (context) => const ItemListScreen()));
        },
        tooltip: 'Kembali',
        child: const Icon(Icons.arrow_left_sharp),
      ),
    );
  }

  Widget buildUserListView(List<Txns?> transactions) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        Txns? transaction = transactions[index];
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
                "${transaction!.userId.toString()} | ${transaction.status}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                children: [
                  Text(
                    "Total: ${formatUang(transaction.total)}",
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Tanggal: ${transaction.createdAt}",
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.check_circle, color: Colors.redAccent),
                    onPressed: () {
                      _showApprovedDialog(transaction);
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

  void _showApprovedDialog(Txns transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Setujui"),
          content: Text("Apakah anda yakin ingin menyetujui transaksi sejumlah ${formatUang(transaction.total)} ini"),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              child:
                  const Text("Setuju", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                try {
                  Repo.instance.approvedTransaction(transaction);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Transaksi berhasil disetujui!"),
                    ),
                  );
                  await _refreshTransactionsList();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menyetujui transaksi: $e")),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
