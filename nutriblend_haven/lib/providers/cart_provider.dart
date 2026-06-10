import 'package:flutter/material.dart';

class CartItem {
  final int id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get lineTotal => price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  // Legacy getter for screens that still use Map<String, dynamic>
  List<Map<String, dynamic>> get cart => _items
      .map((i) => {'id': i.id, 'name': i.name, 'price': i.price, 'quantity': i.quantity})
      .toList();

  int get cartCount => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalItems => _items.length;

  double get totalAmount => _items.fold(0, (sum, i) => sum + i.lineTotal);

  int getQuantity(int productId) {
    final idx = _items.indexWhere((i) => i.id == productId);
    return idx != -1 ? _items[idx].quantity : 0;
  }

  bool isInCart(int productId) => _items.any((i) => i.id == productId);

  void addToCart(Map<String, dynamic> product) {
    final id = product['id'] as int;
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx].quantity += 1;
    } else {
      _items.add(CartItem(
        id: id,
        name: product['name'] as String,
        price: double.tryParse(product['price']?.toString() ?? '0') ?? 0,
      ));
    }
    notifyListeners();
  }

  void increaseQuantity(Map<String, dynamic> product) => addToCart(product);

  void decreaseQuantity(Map<String, dynamic> product) {
    final id = product['id'] as int;
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    if (_items[idx].quantity > 1) {
      _items[idx].quantity -= 1;
    } else {
      _items.removeAt(idx);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _items.removeWhere((i) => i.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
