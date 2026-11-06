import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/product_provider.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = context.read<ProductProvider>();
      provider.fetchProducts();
      provider.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DummyJSON Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari Produk (Search)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => provider.searchProducts(val),
            ),
          ),
          if (provider.categoryList.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categoryList.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: const Text('All'),
                        onPressed: () => provider.fetchProducts(),
                      ),
                    );
                  }
                  final cat = provider.categoryList[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: Text(cat),
                      onPressed: () => provider.filterByCategory(cat),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final prod = provider.products[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: prod.thumbnail,
                          width: 50,
                          height: 50,
                          placeholder: (c, u) => const CircularProgressIndicator(),
                          errorWidget: (c, u, e) => const Icon(Icons.error),
                        ),
                        title: Text(prod.title),
                        subtitle: Text('\$${prod.price} | Rating: ${prod.rating}'),
                        onTap: () => context.push('/detail/${prod.id}', extra: prod),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final success = await provider.deleteProduct(prod.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Produk berhasil dihapus (Mock)')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}