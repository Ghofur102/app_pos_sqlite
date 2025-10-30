import 'package:app_pos_sqlite/components/header.dart';
import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/txns.dart';
import 'package:flutter/material.dart';
import 'package:app_pos_sqlite/utils/format_uang.dart';
class MyListTransactionsScreen extends StatelessWidget {
  const MyListTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyListTransactionsScreenPage();
  }
}

class MyListTransactionsScreenPage extends StatefulWidget {
  const MyListTransactionsScreenPage({super.key});

  @override
  State<MyListTransactionsScreenPage> createState() => _MyListTransactionsScreenState();
}

class _MyListTransactionsScreenState extends State<MyListTransactionsScreenPage> {

  late Future<List<Txns?>> _futureTransactions;

  @override
  void initState() {
    super.initState();
    _futureTransactions = Repo.instance.getMyTransactions();
  }

  void _refreshTransactionsList() {
    setState(() {
      _futureTransactions = Repo.instance.getMyTransactions();
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Center(
        child: FutureBuilder(
          future: _futureTransactions,
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
            ),
          ),
        );
      },
    );
  }
}
