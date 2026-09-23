import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }
  
  int get uniqueItemCount => _items.length;

  double get subtotal {
    return _items.values
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get discount {
    // Discount: 10% if subtotal is above ৳2000
    if (subtotal > 2000) {
      return subtotal * 0.10;
    }
    return 0.0;
  }

  double get finalTotal {
    return subtotal - discount;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity -= 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
