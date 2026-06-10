import '../utils/app_snackbar.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  int _quantity = 1;

  static const _bgs = [
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFFE0F7FA),
    Color(0xFFFCE4EC),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final int id = (product['id'] ?? 0) as int;
    final String name = (product['name'] ?? 'Product').toString().trim();
    final String price = (product['formatted_price'] ?? '') as String;
    final String image = (product['main_image'] ?? '') as String;
    final String description = (product['description'] ?? '').toString();
    final bool inStock = (product['in_stock'] ?? true) as bool;
    final Map<String, dynamic>? category =
        product['category'] as Map<String, dynamic>?;
    final String categoryName =
        category != null ? (category['name'] ?? '') as String : '';
    final bg = _bgs[id % _bgs.length];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context, id, image, bg, name),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: _buildBody(
                      context,
                      id: id,
                      name: name,
                      price: price,
                      description: description,
                      inStock: inStock,
                      categoryName: categoryName,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Bottom Add-to-Cart Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context, id, name, price, inStock),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, int id, String image, Color bg,
      String name) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlist, _) {
        final isWished = wishlist.isInWishlist(id);
        return SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.black87, size: 20),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                wishlist.toggleWishlist(widget.product);
                showAppSnackBar(
                  context,
                  isWished ? 'Removed from wishlist' : 'Added to wishlist',
                  success: true,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isWished ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isWished ? AppTheme.primaryColor : Colors.black54,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: bg,
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.local_pharmacy_outlined,
                            color: Colors.grey.shade400, size: 64),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.local_pharmacy_outlined,
                          color: Colors.grey.shade400, size: 64),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required int id,
    required String name,
    required String price,
    required String description,
    required bool inStock,
    required String categoryName,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          if (categoryName.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categoryName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Product Name
          Text(
            name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Price & Stock Row
          Row(
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: inStock
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: inStock
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: inStock
                            ? Colors.green.shade500
                            : Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      inStock ? 'In Stock' : 'Out of Stock',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: inStock
                            ? Colors.green.shade700
                            : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider
          Divider(color: Colors.grey.shade100, thickness: 1.5),
          const SizedBox(height: 20),

          // Quantity Selector
          if (inStock) ...[
            Text(
              'Quantity',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove_rounded,
                  onTap: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                const SizedBox(width: 16),
                Text(
                  '$_quantity',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                _QtyButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.shade100, thickness: 1.5),
            const SizedBox(height: 20),
          ],

          // Description
          Text(
            'About this product',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description.isNotEmpty
                ? description.replaceAll(RegExp(r'<[^>]*>'), '')
                : 'No description available for this product.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: Colors.grey.shade600,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int id, String name,
      String price, bool inStock) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final inCart = cart.isInCart(id);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: inStock
                  ? () {
                      for (int i = 0; i < _quantity; i++) {
                        cart.addToCart({
                          'id': id,
                          'name': name,
                          'price': widget.product['price'] ??
                              widget.product['formatted_price'] ??
                              0,
                        });
                      }
                      ScaffoldMessenger.of(context).clearSnackBars();
                      showAppSnackBar(
                        context,
                        inCart ? 'Cart updated!' : '${_quantity}x $name added to cart!',
                        success: true,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    inStock ? AppTheme.primaryColor : Colors.grey.shade300,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    inCart
                        ? Icons.shopping_cart_rounded
                        : Icons.add_shopping_cart_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    inStock
                        ? (inCart ? 'Add More to Cart' : 'Add to Cart')
                        : 'Out of Stock',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryColor
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}
