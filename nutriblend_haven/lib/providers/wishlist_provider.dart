import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  int get count => _wishlist.length;

  bool isLoved(dynamic productId) {
    return _wishlist.any((item) => item['id'] == productId);
  }

  void toggleWishlist(Map<String, dynamic> product) {
    final index = _wishlist.indexWhere((item) => item['id'] == product['id']);
    if (index != -1) {
      _wishlist.removeAt(index);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }
  final Set<int> _ids = {};

  bool isWishlisted(int id) => _ids.contains(id);

  void toggle(int id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }

  int get count => _ids.length;
}
