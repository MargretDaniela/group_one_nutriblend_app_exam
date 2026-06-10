import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/theme.dart';

/// Single reusable product card used in both HomeScreen and ProductsScreen.
/// Set [isFeatured] to true for the horizontal scroll strip (narrower card).
class ProductGridCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFeatured;

  const ProductGridCard({
    super.key,
    required this.product,
    this.isFeatured = false,
  });

  static const _bgs = [
    Color(0xFFE0F2F1), Color(0xFFFFF8E1),
    Color(0xFFEDE7F6), Color(0xFFE1F5FE),
    Color(0xFFFCE4EC), Color(0xFFF1F8E9),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final wl = Provider.of<WishlistProvider>(context);

    final image = (product['main_image'] ?? '') as String;
    final name = (product['name'] ?? 'Product').toString().trim();
    final price = (product['formatted_price'] ?? '') as String;
    final category = (product['category']?['name'] ?? '') as String;
    final bool inStock = (product['in_stock'] ?? true) as bool;
    final int id = (product['id'] ?? 0) as int;

    final bg = _bgs[id % _bgs.length];
    final inCart = cart.isInCart(id);
    final wishlisted = wl.isWishlisted(id);

    final double cardWidth = isFeatured ? 148.0 : double.infinity;
    final double imageHeight = isFeatured ? 110.0 : double.infinity;

    return Container(
      width: isFeatured ? cardWidth : null,
      margin: isFeatured ? const EdgeInsets.only(right: 12) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image area ──────────────────────────────────────────────────────
          isFeatured
              ? _ImageSection(
                  image: image, bg: bg, inStock: inStock,
                  wishlisted: wishlisted, onWishlist: () => wl.toggle(id),
                  height: imageHeight, borderRadius: 20,
                )
              : Expanded(
                  flex: 55,
                  child: _ImageSection(
                    image: image, bg: bg, inStock: inStock,
                    wishlisted: wishlisted, onWishlist: () => wl.toggle(id),
                    height: null, borderRadius: 20,
                  ),
                ),

          // ── Info area ────────────────────────────────────────────────────────
          isFeatured
              ? _InfoSection(
                  name: name, price: price, category: category,
                  inStock: inStock, inCart: inCart, isFeatured: true,
                  onAddToCart: _addToCart(context, cart, id, name, price),
                )
              : Expanded(
                  flex: 45,
                  child: _InfoSection(
                    name: name, price: price, category: category,
                    inStock: inStock, inCart: inCart, isFeatured: false,
                    onAddToCart: _addToCart(context, cart, id, name, price),
                  ),
                ),
        ],
      ),
    );
  }

  VoidCallback? _addToCart(
    BuildContext context,
    CartProvider cart,
    int id,
    String name,
    String formattedPrice,
  ) {
    final bool inStock = (product['in_stock'] ?? true) as bool;
    if (!inStock) return null;
    return () {
      cart.addToCart({
        'id': id,
        'name': name,
        'price': product['price'] ?? formattedPrice,
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text(
            cart.isInCart(id) ? 'Quantity updated' : 'Added to cart',
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 1),
        ));
    };
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final String image;
  final Color bg;
  final bool inStock;
  final bool wishlisted;
  final VoidCallback onWishlist;
  final double? height;
  final double borderRadius;

  const _ImageSection({
    required this.image, required this.bg, required this.inStock,
    required this.wishlisted, required this.onWishlist,
    required this.height, required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imgWidget = image.isNotEmpty
        ? Image.network(image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder())
        : _placeholder();

    if (height != null) {
      imgWidget = SizedBox(height: height, width: double.infinity, child: imgWidget);
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
          child: Container(
            width: double.infinity, color: bg, child: imgWidget),
        ),
        if (!inStock)
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(borderRadius)),
              child: Container(
                color: Colors.black.withOpacity(0.42),
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text('OUT OF STOCK',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5)),
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onWishlist,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 6)
                ],
              ),
              child: Icon(
                wishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: wishlisted ? Colors.red.shade400 : Colors.grey.shade400,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Center(
        child: Icon(Icons.local_pharmacy_outlined,
            color: Colors.grey.shade400, size: 36),
      );
}

class _InfoSection extends StatelessWidget {
  final String name;
  final String price;
  final String category;
  final bool inStock;
  final bool inCart;
  final bool isFeatured;
  final VoidCallback? onAddToCart;

  const _InfoSection({
    required this.name, required this.price, required this.category,
    required this.inStock, required this.inCart, required this.isFeatured,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.isNotEmpty && !isFeatured)
                Text(category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3)),
              if (!isFeatured) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: inStock
                            ? Colors.green.shade500
                            : Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      inStock ? 'In Stock' : 'Out of Stock',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: inStock
                              ? Colors.green.shade600
                              : Colors.red.shade400),
                    ),
                  ],
                ),
              ],
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(price,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onAddToCart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: inStock && !inCart
                        ? const LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)
                        : null,
                    color: inStock
                        ? (inCart ? const Color(0xFFE0F2F1) : null)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    inCart ? Icons.check_rounded : Icons.add_rounded,
                    color: inStock
                        ? (inCart ? AppTheme.primaryColor : Colors.white)
                        : Colors.grey.shade400,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
