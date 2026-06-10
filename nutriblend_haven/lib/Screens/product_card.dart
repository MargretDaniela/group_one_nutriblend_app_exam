import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/theme.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isFeatured;

  const ProductCard({
    super.key,
    required this.product,
    this.isFeatured = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late final int _productId;
  late final String _name;
  late final String _price;
  late final String _image;
  late final bool _inStock;
  bool _isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    _productId = widget.product['id'] ?? 0;
    _name = widget.product['name'] ?? 'Product';
    _price = widget.product['formatted_price'] ?? '';
    _image = widget.product['main_image'] ?? '';
    _inStock = widget.product['in_stock'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WishlistProvider, CartProvider>(
      builder: (context, wishlistProvider, cartProvider, child) {
        final bool inWishlist = wishlistProvider.isInWishlist(_productId);
        final bool inCart = cartProvider.isInCart(_productId);

        return Container(
          width: widget.isFeatured ? 148 : double.infinity,
          margin: widget.isFeatured ? const EdgeInsets.only(right: 12) : null,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with wishlist button
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Container(
                      height: widget.isFeatured ? 110 : 150,
                      width: double.infinity,
                      color: AppTheme.primaryLight,
                      child: _image.isNotEmpty
                          ? Image.network(
                              _image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.local_pharmacy_outlined,
                                color: AppTheme.textSecondary,
                                size: 36,
                              ),
                            )
                          : Icon(
                              Icons.local_pharmacy_outlined,
                              color: AppTheme.textSecondary,
                              size: 36,
                            ),
                    ),
                    // Wishlist button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _isWishlistLoading = true);
                          try {
                            wishlistProvider.toggleWishlist(_productId);
                            if (mounted) {
                              setState(() => _isWishlistLoading = false);
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    inWishlist ? 'Removed from wishlist' : 'Added to wishlist',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                  ),
                                  backgroundColor: inWishlist ? AppTheme.errorColor : AppTheme.successColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isWishlistLoading = false);
                            }
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.shadowColor,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isWishlistLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  ),
                                )
                              : Icon(
                                  inWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: inWishlist ? AppTheme.accentColor : AppTheme.textSecondary,
                                  size: 18,
                                ),
                        ),
                      ),
                    ),
                    // Out of stock overlay
                    if (!_inStock)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.45),
                          child: Center(
                            child: Text(
                              'OUT OF STOCK',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.isFeatured ? 10 : 11,
                    widget.isFeatured ? 8 : 9,
                    widget.isFeatured ? 10 : 11,
                    widget.isFeatured ? 10 : 11,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _name,
                        maxLines: widget.isFeatured ? 2 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: widget.isFeatured ? 12 : 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (!widget.isFeatured) ...[
                        Text(
                          _inStock ? '● In Stock' : '● Out of Stock',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _inStock
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(height: 7),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _price,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.primaryColor,
                                fontSize: widget.isFeatured ? 12 : 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (widget.isFeatured) const SizedBox(width: 6),
                          if (widget.isFeatured)
                            GestureDetector(
                              onTap: _inStock
                                  ? () {
                                      cartProvider.addToCart({
                                        'id': _productId,
                                        'name': _name,
                                        'price': widget.product['price'] ?? _price,
                                      });
                                      ScaffoldMessenger.of(context)
                                        ..clearSnackBars()
                                        ..showSnackBar(SnackBar(
                                          content: Text(
                                            'Added to cart',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                          ),
                                          backgroundColor: AppTheme.primaryColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                          duration: const Duration(seconds: 1),
                                        ));
                                    }
                                  : null,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _inStock
                                      ? AppTheme.primaryColor
                                      : AppTheme.dividerColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add_rounded,
                                  color: _inStock ? Colors.white : AppTheme.textSecondary,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}