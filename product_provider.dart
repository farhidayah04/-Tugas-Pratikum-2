import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service_products.dart';

class ProductProvider extends ChangeNotifier {
  final ApiServiceProducts _api = ApiServiceProducts();

  List<Product> _products = [];
  List<String> _categoryList = [];
  bool _loading = false;
  String? _error;
  int _total = 0;

  List<Product> get products => _products;
  List<String> get categoryList => _categoryList;
  bool get loading => _loading;
  int get total => _total;
  String? get error => _error;

  Future<void> fetchProducts({int limit = 30, int skip = 0}) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.getAllProducts(limit: limit, skip: skip);
      _products = res.products;
      _total = res.total;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categoryList = await _api.getCategoryList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) return fetchProducts();
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.searchProducts(query);
      _products = res.products;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> filterByCategory(String category) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.getProductsByCategory(category);
      _products = res.products;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _api.addProduct(data);
      _products.insert(0, result);
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, Product updated) async {
    _loading = true;
    notifyListeners();
    try {
      final result = await _api.updateProduct(id, updated.toJson());
      int idx = _products.indexWhere((p) => p.id == id);
      if (idx != -1) _products[idx] = result;
      _loading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await _api.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}