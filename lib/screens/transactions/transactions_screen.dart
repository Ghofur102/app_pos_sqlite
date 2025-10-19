import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionsScreen> {
  late Map<String, dynamic> transactions;
  late Map<String, Map<String, dynamic>> detailPesanan;
  late int totalHargaPesanan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    transactions = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    detailPesanan = Map<String, Map<String, dynamic>>.from(transactions["pesanan"]);
    totalHargaPesanan = transactions["total"] as int;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: Column(
        children: [
          SizedBox(height: 20),
          const Text(
            "Pembelian Makanan & Minuman",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
