import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';

class DetailProductScreen extends StatelessWidget {
  final Product product;
  const DetailProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit/${product.id}', extra: product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                height: 200,
              ),
            ),
            const SizedBox(height: 16),
            Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Brand: ${product.brand}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Price: \$${product.price}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 16),
            Text('Category: ${product.category}'),
            Text('Stock: ${product.stock}'),
            Text('Rating: ${product.rating}'),
          ],
        ),
      ),
    );
  }
}