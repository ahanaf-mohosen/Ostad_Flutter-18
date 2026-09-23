import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final List<Product> _allProducts = [
    Product(id: '1', name: 'MacBook Pro', price: 250000, icon: '💻'),
    Product(id: '2', name: 'iPhone 15', price: 120000, icon: '📱'),
    Product(id: '3', name: 'AirPods Pro', price: 25000, icon: '🎧'),
    Product(id: '4', name: 'Apple Watch', price: 40000, icon: '⌚'),
    Product(id: '5', name: 'iPad Air', price: 60000, icon: '💊'),
    Product(id: '6', name: 'Magic Mouse', price: 10000, icon: '🖱️'),
    Product(id: '7', name: 'Keyboard', price: 15000, icon: '⌨️'),
    Product(id: '8', name: 'Monitor', price: 80000, icon: '🖥️'),
  ];

  String _searchQuery = '';

  List<Product> get products {
    if (_searchQuery.isEmpty) {
      return _allProducts;
    }
    return _allProducts
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
