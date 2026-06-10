import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(Icons.home, 'Home', 0),
        _buildNavItem(Icons.grid_view, 'Products', 1),
        _buildNavItem(
          Icons.shopping_cart,
          'Cart',
          2,
          badge: cartProvider.cartCount > 0
              ? Text(
                  '${cartProvider.cartCount}',
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        _buildNavItem(Icons.person, 'Profile', 3),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index, {
    Widget? badge,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          if (badge != null)
            Positioned(
              right: -2,
              top: -2,
              child: badge,
            ),
        ],
      ),
      label: label,
    );
  }
}