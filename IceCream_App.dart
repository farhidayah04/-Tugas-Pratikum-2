import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const IceCreamApp());
}

class IceCreamApp extends StatelessWidget {
  const IceCreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Best Icecream App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEC407A),
          primary: const Color(0xFFEC407A),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    IceCreamHomeScreen(),
    IceCreamCartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFFEC407A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.icecream), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}

class IceCreamHomeScreen extends StatefulWidget {
  const IceCreamHomeScreen({super.key});

  @override
  State<IceCreamHomeScreen> createState() => _IceCreamHomeScreenState();
}

class _IceCreamHomeScreenState extends State<IceCreamHomeScreen> {
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  List<String> _categories = ['All'];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<IconData> _categoryIcons = const [
    Icons.apps,
    Icons.brush_outlined,
    Icons.science_outlined,
    Icons.chair_outlined,
    Icons.local_grocery_store_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 1. Fetch Produk
      final prodResponse = await http.get(Uri.parse('https://dummyjson.com/products'));
      // 2. Fetch Kategori
      final catResponse = await http.get(Uri.parse('https://dummyjson.com/products/categories'));

      if (prodResponse.statusCode == 200 && mounted) {
        final prodData = json.decode(prodResponse.body);
        _allProducts = prodData['products'] ?? [];
        _filteredProducts = _allProducts;
      }

      if (catResponse.statusCode == 200 && mounted) {
        final catData = json.decode(catResponse.body);
        List<String> fetchedCats = ['All'];
        for (var item in catData) {
          if (item is Map && item.containsKey('slug')) {
            fetchedCats.add(item['slug'].toString());
          } else if (item is String) {
            fetchedCats.add(item);
          }
        }
        _categories = fetchedCats;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FITUR FILTER GABUNGAN (SEARCH + KATEGORI)
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();

    final filtered = _allProducts.where((product) {
      final title = (product['title'] ?? '').toString().toLowerCase();
      final category = (product['category'] ?? '').toString().toLowerCase();

      final matchesSearch = title.contains(query) || category.contains(query);
      final matchesCategory = _selectedCategory == 'All' || category == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();

    setState(() => _filteredProducts = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFEC407A)))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // BANNER ATAS PINK
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC407A),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.notes, color: Colors.white, size: 28),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 140,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0x3FFFFFFF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (_) => _filterProducts(),
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      decoration: const InputDecoration(
                                        hintText: 'Search...',
                                        hintStyle: TextStyle(color: Colors.white70),
                                        prefixIcon: Icon(Icons.search, color: Colors.white, size: 18),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const IceCreamCartScreen()),
                                      );
                                    },
                                  ),
                                  const CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('Hello Roee, Choose Your', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('Best Icecream', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // LIST KATEGORI FUNGSIONAL
                    SizedBox(
                      height: 75,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final categoryName = _categories[index];
                          final isSelected = _selectedCategory == categoryName;
                          final iconData = _categoryIcons[index % _categoryIcons.length];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = categoryName;
                                _filterProducts();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFEC407A) : const Color(0xFFFCE4EC),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: isSelected ? Colors.white : const Color(0xFFEC407A),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    categoryName.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFFEC407A) : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // GRID PRODUK BERDASARKAN KATEGORI
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _filteredProducts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Tidak ada produk dalam kategori ini',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: _filteredProducts.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.82,
                              ),
                              itemBuilder: (context, index) {
                                return IceCreamCard(product: _filteredProducts[index]);
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

class IceCreamCard extends StatefulWidget {
  final dynamic product;

  const IceCreamCard({super.key, required this.product});

  @override
  State<IceCreamCard> createState() => _IceCreamCardState();
}

class _IceCreamCardState extends State<IceCreamCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final String title = (widget.product['title'] ?? '').toString();
    final String price = (widget.product['price'] ?? 0).toString();
    final String thumbnail = (widget.product['thumbnail'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IceCreamDetailScreen(product: widget.product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8BBD0),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: thumbnail.isNotEmpty
                            ? Image.network(thumbnail, fit: BoxFit.cover)
                            : const Icon(Icons.icecream, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                  ),
                ),
                const Text('Rolled Ice Cream', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('\$$price', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 10,
              bottom: 35,
              child: GestureDetector(
                onTap: () => setState(() => isFavorite = !isFavorite),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: const Color(0xFFEC407A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IceCreamCartScreen extends StatefulWidget {
  const IceCreamCartScreen({super.key});

  @override
  State<IceCreamCartScreen> createState() => _IceCreamCartScreenState();
}

class _IceCreamCartScreenState extends State<IceCreamCartScreen> {
  final cartItems = [
    {
      'name': 'BANANA',
      'sub': 'Rolled Ice Cream',
      'price': 10.39,
      'qty': 3,
      'image': 'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png'
    },
    {
      'name': 'MANGO',
      'sub': 'Rolled Ice Cream',
      'price': 9.84,
      'qty': 4,
      'image': 'https://cdn.dummyjson.com/products/images/beauty/Eyeshadow%20Palette%20with%20Mirror/thumbnail.png'
    },
    {
      'name': 'GUAVA',
      'sub': 'Rolled Ice Cream',
      'price': 8.15,
      'qty': 1,
      'image': 'https://cdn.dummyjson.com/products/images/beauty/Powder%20Canister/thumbnail.png'
    },
  ];

  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) {
      final double price = (item['price'] as num).toDouble();
      final int qty = (item['qty'] as num).toInt();
      return sum + (price * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8BBD0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Cart', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  final int qty = (item['qty'] as num).toInt();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(item['image'].toString(), width: 55, height: 55, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(item['sub'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 6),
                              const Row(
                                children: [
                                  Icon(Icons.favorite, size: 16, color: Color(0xFFEC407A)),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete_outline, size: 16, color: Color(0xFFEC407A)),
                                ],
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              qty.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEC407A)),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => item['qty'] = qty + 1),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.add, size: 14, color: Color(0xFFEC407A)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () {
                                    if (qty > 1) setState(() => item['qty'] = qty - 1);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: const Color(0xFFFCE4EC), borderRadius: BorderRadius.circular(4)),
                                    child: const Icon(Icons.remove, size: 14, color: Color(0xFFEC407A)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: const Color(0xFFF48FB1), borderRadius: BorderRadius.circular(15)),
              child: Center(
                child: Text('Total \$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('Place Order', style: TextStyle(color: Color(0xFFEC407A), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IceCreamDetailScreen extends StatelessWidget {
  final dynamic product;

  const IceCreamDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String title = (product['title'] ?? '').toString();
    final String price = (product['price'] ?? 0).toString();
    final String thumbnail = (product['thumbnail'] ?? '').toString();
    final String description = (product['description'] ?? 'No description available.').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: thumbnail.isNotEmpty
                      ? Image.network(thumbnail)
                      : const Icon(Icons.icecream, size: 80, color: Color(0xFFEC407A)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('\$$price', style: const TextStyle(fontSize: 22, color: Color(0xFFEC407A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC407A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Add To Cart', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}