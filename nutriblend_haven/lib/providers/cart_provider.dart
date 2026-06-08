import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  final List<Map<String, dynamic>> _cart = [];

  List<Map<String, dynamic>> get cart => _cart;

  int get cartCount {
    return _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  double get totalAmount {
    return _cart.fold(0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0;
      return sum + (price * (item['quantity'] as int));
    });
  }

  int getQuantity(dynamic productId) {
    final index = _cart.indexWhere((item) => item['id'] == productId);
    if (index != -1) return _cart[index]['quantity'] as int;
    return 0;
  }

  void addToCart(Map<String, dynamic> product) {
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _cart[index]['quantity'] += 1;
    } else {
      _cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void increaseQuantity(Map<String, dynamic> product) {
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _cart[index]['quantity'] += 1;
    } else {
      _cart.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void decreaseQuantity(Map<String, dynamic> product) {
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      if (_cart[index]['quantity'] > 1) {
        _cart[index]['quantity'] -= 1;
      } else {
        _cart.removeAt(index);
      }
    }
    notifyListeners(); 
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}