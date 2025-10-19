import 'package:flutter/material.dart';

class TxnDetailScreen extends StatelessWidget {
  const TxnDetailScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Transaksi")),
      body: const Center(child: Text("Detail Transaksi"))
    );
  }
  
}
