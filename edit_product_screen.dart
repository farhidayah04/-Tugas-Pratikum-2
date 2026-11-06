import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _titleController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Produk (PUT)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 1. Buat objek Product baru menggunakan copyWith
                final updatedProduct = widget.product.copyWith(
                  title: _titleController.text,
                  price: double.tryParse(_priceController.text) ?? widget.product.price,
                );

                // 2. Kirim objek Product (bukan Map) ke updateProduct
                final success = await context.read<ProductProvider>().updateProduct(
                      widget.product.id,
                      updatedProduct,
                    );

                // 3. Kembali ke halaman sebelumnya jika berhasil
                if (success && context.mounted) {
                  context.pop();
                }
              },
              child: const Text('Update'),
            )
          ],
        ),
      ),
    );
  }
}