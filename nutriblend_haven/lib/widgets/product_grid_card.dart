import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/theme.dart';
import '../utils/app_snackbar.dart';

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

  // Subtle pastel backgrounds per-product slot
  static const _bgs = [
    Color(0xFFEFF6EE), Color(0xFFFFF8EE),
    Color(0xFFEEF2FF), Color(0xFFEEF8FF),
    Color(0xFFFFF0EE), Color(0xFFF0FAF4),
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

    final double rating =
        double.tryParse(product['rating']?.toString() ?? '') ??
            (3.0 + (id % 21) / 10.0);
    final int reviewsCount =
        int.tryParse(product['reviews_count']?.toString() ?? '') ??
            (12 + (id * 7) % 250);

    final bg = _bgs[id % _bgs.length];
    final inCart = cart.isInCart(id);
    final wishlisted = wl.isInWishlist(id);

    return Container(
      width: isFeatured ? 148.0 : null,
      margin: isFeatured ? const EdgeInsets.only(right: 12) : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fixed-height image area ─────────────────────────────────────────
          _ImageSection(
            image: image,
            bg: bg,
            inStock: inStock,
            wishlisted: wishlisted,
            onWishlist: () {
              wl.toggleWishlist(product);
              showAppSnackBar(
                context,
                wl.isInWishlist(id) ? 'Added to wishlist' : 'Removed from wishlist',
                success: true,
              );
            },
            isFeatured: isFeatured,
          ),

          // ── Info area ───────────────────────────────────────────────────────
          Expanded(
            child: _InfoSection(
              name: name,
              price: price,
              category: category,
              inStock: inStock,
              inCart: inCart,
              isFeatured: isFeatured,
              rating: rating,
              reviewsCount: reviewsCount,
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
      final wasInCart = cart.isInCart(id);
      cart.addToCart({
        'id': id,
        'name': name,
        'price': product['price'] ?? formattedPrice,
      });
      showAppSnackBar(
        context,
        wasInCart ? 'Cart quantity updated' : '$name added to cart',
        success: true,
      );
    };
  }
}

// ── Image section ─────────────────────────────────────────────────────────────

class _ImageSection extends StatelessWidget {
  final String image;
  final Color bg;
  final bool inStock;
  final bool wishlisted;
  final VoidCallback onWishlist;
  final bool isFeatured;

  const _ImageSection({
    required this.image,
    required this.bg,
    required this.inStock,
    required this.wishlisted,
    required this.onWishlist,
    required this.isFeatured,
  });

  // Fixed heights so all cards are exactly the same
  double get _imageHeight => isFeatured ? 108.0 : 130.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fixed-size image container — ensures uniform height across all cards
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SizedBox(
            width: double.infinity,
            height: _imageHeight,
            child: ColoredBox(
              color: bg,
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: _imageHeight,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
        ),
        // Out of stock overlay
        if (!inStock)
          Positioned.fill(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: Colors.black.withOpacity(0.40),
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'OUT OF STOCK',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Wishlist button
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onWishlist,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                wishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color:
                    wishlisted ? const Color(0xFFE53935) : Colors.grey.shade400,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() => Center(
        child: Icon(Icons.local_pharmacy_outlined,
            color: Colors.grey.shade300, size: 32),
      );
}

// ── Info section ─────────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String name;
  final String price;
  final String category;
  final bool inStock;
  final bool inCart;
  final bool isFeatured;
  final double rating;
  final int reviewsCount;
  final VoidCallback? onAddToCart;

  const _InfoSection({
    required this.name,
    required this.price,
    required this.category,
    required this.inStock,
    required this.inCart,
    required this.isFeatured,
    required this.rating,
    required this.reviewsCount,
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
          // Category + name + stars
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.isNotEmpty && !isFeatured)
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              // Star row
              Row(
                children: [
                  ...List.generate(5, (i) {
                    if (rating >= i + 1) {
                      return const Icon(Icons.star_rounded,
                          color: Color(0xFFFFA500), size: 11);
                    } else if (rating >= i + 0.5) {
                      return const Icon(Icons.star_half_rounded,
                          color: Color(0xFFFFA500), size: 11);
                    } else {
                      return Icon(Icons.star_rounded,
                          color: Colors.grey.shade200, size: 11);
                    }
                  }),
                  const SizedBox(width: 3),
                  Text(
                    '($reviewsCount)',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Price + add button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  price,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF007A3D),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onAddToCart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: !inStock
                        ? Colors.grey.shade100
                        : inCart
                            ? const Color(0xFFE8F7EF)
                            : const Color(0xFF00A651),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    inCart ? Icons.check_rounded : Icons.add_rounded,
                    color: !inStock
                        ? Colors.grey.shade300
                        : inCart
                            ? const Color(0xFF00A651)
                            : Colors.white,
                    size: 17,
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
