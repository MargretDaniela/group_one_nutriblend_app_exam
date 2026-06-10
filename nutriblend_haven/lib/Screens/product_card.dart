import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
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
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _productId = widget.product['id'] ?? 0;
    _name = widget.product['name'] ?? 'Product';
    _price = widget.product['formatted_price'] ?? '';
    _image = widget.product['main_image'] ?? '';
    _inStock = widget.product['in_stock'] ?? true;
    _isInWishlist = widget.product['is_in_wishlist'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final bool inWishlist = _isInWishlist;
        final bool inCart = cartProvider.isInCart(_productId);

        return Container(
          width: widget.isFeatured ? 148 : double.infinity,
          margin: widget.isFeatured ? const EdgeInsets.only(right: 12) : null,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with wishlist button
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
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
                        onTap: () {
                          final bool isNowInWishlist = !_isInWishlist;
                          setState(() => _isInWishlist = isNowInWishlist);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isNowInWishlist
                                    ? 'Added to wishlist'
                                    : 'Removed from wishlist',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                ),
                              ),
                              backgroundColor: isNowInWishlist
                                  ? Colors.green
                                  : Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            inWishlist
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: inWishlist
                                ? Colors.redAccent
                                : AppTheme.textSecondary,
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
              Padding(
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
                      maxLines: 2,
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
                          color: _inStock ? Colors.green : Colors.redAccent,
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
                            onTap: _inStock && !inCart
                                ? () {
                                    cartProvider.addToCart({
                                      'id': _productId,
                                      'name': _name,
                                      'price':
                                          widget.product['price'] ?? _price,
                                    });
                                    ScaffoldMessenger.of(context)
                                      ..clearSnackBars()
                                      ..showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added to cart',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                            ),
                                          ),
                                          backgroundColor:
                                              AppTheme.primaryColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                            16,
                                            0,
                                            16,
                                            16,
                                          ),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                  }
                                : null,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _inStock && !inCart
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add_rounded,
                                color: _inStock && !inCart
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
