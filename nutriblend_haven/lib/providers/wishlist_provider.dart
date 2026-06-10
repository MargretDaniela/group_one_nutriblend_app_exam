import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<int> _wishlistItems = {};

  Set<int> get wishlistItems => Set.unmodifiable(_wishlistItems);

  bool isInWishlist(int productId) => _wishlistItems.contains(productId);

  void addToWishlist(int productId) {
    if (!_wishlistItems.contains(productId)) {
      _wishlistItems.add(productId);
      notifyListeners();
    }
  }

  void removeFromWishlist(int productId) {
    if (_wishlistItems.contains(productId)) {
      _wishlistItems.remove(productId);
      notifyListeners();
    }
  }

  void toggleWishlist(int productId) {
    if (_wishlistItems.contains(productId)) {
      _wishlistItems.remove(productId);
    } else {
      _wishlistItems.add(productId);
    }
    notifyListeners();
  }

  void clearWishlist() {
    if (_wishlistItems.isNotEmpty) {
      _wishlistItems.clear();
      notifyListeners();
    }
  }
}