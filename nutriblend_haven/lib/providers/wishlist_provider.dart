import 'package:flutter/material.dart';

class WishlistProvider extends ChangeNotifier {
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
