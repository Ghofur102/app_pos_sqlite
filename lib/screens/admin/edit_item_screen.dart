import 'package:app_pos_sqlite/db/repository.dart';
import 'package:app_pos_sqlite/models/item.dart';
import 'package:flutter/material.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {

  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _priceController = TextEditingController();
  late TextEditingController _categoryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override  
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item.name
    );
    _priceController = TextEditingController(
      text: widget.item.price.toString()
    );
    _categoryController = TextEditingController(
      text: widget.item.category
    );
  }

  void _submitData() async {
    if(_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Repo.instance.updateItem(
          widget.item.id,
          _nameController.text,
          _priceController.text,
          _categoryController.text
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item "${_nameController.text}" berhasil di tambahkan!')),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengedit item: $e")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override    
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override   
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item (Update)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Menu",
                  hintText: "Masukkan nama menu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  prefixIcon: const Icon(Icons.food_bank),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Nama menu tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Harga Menu",
                  hintText: "Memasukkan harga menu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.monetization_on),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Harga menu tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: "Kategori Menu",
                  hintText: "Memasukkan kategori menu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.category_sharp),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Kategori menu tidak boleh kosong";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submitData, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), textStyle: const TextStyle(fontSize: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10),)), child: const Text("Update Menu"),),
            ],
          ),
        ),
      ),
    );
  }

}