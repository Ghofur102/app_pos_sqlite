import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/utils/format_uang.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionsScreen> {
  late Map<String, dynamic> transactions;
  late Map<String, Map<String, dynamic>> detailPesanan;
  late int totalHargaPesanan;

  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    transactions = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    detailPesanan = Map<String, Map<String, dynamic>>.from(transactions["pesanan"]);
    totalHargaPesanan = transactions["total"] as int;
  }

  Future<void> _simpanTransaksi() async {
    setState(() => _isSaving = true);

    try {
      // Misalnya user_id = 1 untuk sementara
      const userId = 1;

      // Konversi detail pesanan ke format list<Map>
      final items = detailPesanan.entries.map((entry) {
        final data = entry.value;
        return {
          "item_id": data["item_id"] ?? 0, // Pastikan item_id ada
          "quantity": data["quantity"],
          "price": data["price"],
        };
      }).toList();

      await Repo.instance.saveTransaction(userId, totalHargaPesanan, items);

      Fluttertoast.showToast(
        msg: "Transaksi berhasil disimpan!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pushNamedAndRemoveUntil(context, "/menu", (route) => false);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Gagal menyimpan transaksi: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Pembelian Makanan & Minuman",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  children: detailPesanan.entries.map((entry) {
                    final pesanan = entry.value;
                    return ListTile(
                      title: Text(pesanan["name"]),
                      subtitle: Text(
                          "${pesanan["category"]} • Qty: ${pesanan["quantity"]}"),
                      trailing: Text(formatUang(pesanan["subtotal"])),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Total: ${formatUang(totalHargaPesanan)}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _simpanTransaksi,
              icon: const Icon(Icons.save),
              label: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Simpan Transaksi"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
