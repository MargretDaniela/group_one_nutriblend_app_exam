import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'checkout_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const String _baseUrl =
      'https://testing.rasmuspharmaceuticals.com/api/v1';

  List<dynamic> _products = [];
  bool _isLoading = true;
  bool _hasError = false;

  final List<Map<String, dynamic>> _cart = [];
  final Set<dynamic> _favourites = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _products = data['data'] ?? data['products'] ?? data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product['name']} added to cart',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _increaseQuantity(Map<String, dynamic> product) {
    setState(() {
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
    });
  }

  void _decreaseQuantity(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        if (_cart[index]['quantity'] > 1) {
          _cart[index]['quantity'] -= 1;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  int _getQuantity(dynamic productId) {
    final index = _cart.indexWhere((item) => item['id'] == productId);
    if (index != -1) return _cart[index]['quantity'] as int;
    return 0;
  }

  void _toggleFavourite(dynamic productId) {
    setState(() {
      if (_favourites.contains(productId)) {
        _favourites.remove(productId);
      } else {
        _favourites.add(productId);
      }
    });
  }

  int get _cartCount {
    return _cart.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  String _formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    final formatted = number.toStringAsFixed(0);
    final chars = formatted.split('');
    final buffer = StringBuffer();
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(chars[i]);
    }
    return 'UGX ${buffer.toString()}';
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 120, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 80, color: Colors.white),
                    const SizedBox(height: 12),
                    Container(
                      height: 34,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id'];
    final name = product['name'] ?? 'Unknown Product';
    final price = product['price'] ?? 0;
    final shortDescription = product['short_description'] ?? '';
    final description = product['description'] ?? '';
    final imageUrl = product['main_image'] ?? product['image'] ?? '';
    final isFavourite = _favourites.contains(productId);
    final quantity = _getQuantity(productId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 90,
                              height: 90,
                              color: Colors.green[50],
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.green[300],
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 90,
                          height: 90,
                          color: Colors.green[50],
                          child: Icon(
                            Icons.local_pharmacy_outlined,
                            color: Colors.green[300],
                            size: 36,
                          ),
                        ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: GestureDetector(
                    onTap: () => _toggleFavourite(productId),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: isFavourite ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (shortDescription.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      shortDescription,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Html(
                      data: description,
                      style: {
                        'body': Style(
                          fontSize: FontSize(12),
                          color: Colors.grey[600],
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          maxLines: 2,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        'p': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        'strong': Style(fontWeight: FontWeight.normal),
                      },
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(price),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  quantity == 0
                      ? SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () => _addToCart(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child:
                                GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ) !=
                                    null
                                ? Text(
                                    'Add to Cart',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : const Text('Add to Cart'),
                          ),
                        )
                      : Row(
                          children: [
                            GestureDetector(
                              onTap: () => _decreaseQuantity(product),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF2E7D32),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  size: 16,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '$quantity',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _increaseQuantity(product),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.white,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Products',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: _cart.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(cart: _cart),
                          ),
                        );
                      },
              ),
              if (_cartCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _buildShimmerCard(),
            )
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load products',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchProducts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                  ),
                ],
              ),
            )
          : _products.isEmpty
          ? Center(
              child: Text(
                'No products available at the moment',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              color: const Color(0xFF2E7D32),
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(
                    Map<String, dynamic>.from(_products[index]),
                  );
                },
              ),
            ),
    );
  }
}
