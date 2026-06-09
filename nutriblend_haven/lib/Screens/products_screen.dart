import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/reusable_widgets.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _allCategories = ['All', ...AppConstants.categories];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _products = _getMockProducts();
        _filteredProducts = _products;
        _isLoading = false;
      });
    });
  }

  List<Product> _getMockProducts() {
    return [
      Product(
        id: 1,
        name: 'Organic Vitamin C',
        price: 25000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Vitamin+C',
        description: 'Premium quality Vitamin C supplements',
        category: 'Vitamins',
      ),
      Product(
        id: 2,
        name: 'Whey Protein',
        price: 45000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Whey+Protein',
        description: 'Pure whey protein for muscle building',
        category: 'Protein',
      ),
      Product(
        id: 3,
        name: 'Organic Greens',
        price: 35000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Organic+Greens',
        description: 'Organic superfood blend',
        category: 'Organic',
      ),
      Product(
        id: 4,
        name: 'Multivitamin',
        price: 30000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Multivitamin',
        description: 'Complete daily multivitamin',
        category: 'Vitamins',
      ),
      Product(
        id: 5,
        name: 'Collagen',
        price: 55000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Collagen',
        description: 'Hydrolyzed collagen peptides',
        category: 'Beauty',
      ),
      Product(
        id: 6,
        name: 'Turmeric',
        price: 20000,
        imageUrl: 'https://via.placeholder.com/200x150?text=Turmeric',
        description: 'Organic turmeric root extract',
        category: 'Herbal',
      ),
    ];
  }

  void _searchProducts(String query) {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesQuery =
            product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' ||
            product.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      final query = _searchController.text;
      _filteredProducts = _products.where((product) {
        final matchesQuery =
            product.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory =
            category == 'All' || product.category == category;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Products',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SearchBarWidget(
              controller: _searchController,
              onSearch: _searchProducts,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryFilters(),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? _buildShimmerGrid()
                : _hasError
                    ? _buildErrorState()
                    : _filteredProducts.isEmpty
                        ? _buildEmptyState()
                        : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => ShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.red.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Could not load products. Check your connection and try again.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                'Try Again',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppTheme.primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try adjusting your search or selected category.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedCategory != 'All') ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _filterByCategory('All'),
                child: Text(
                  'Clear Filter',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _allCategories.length,
        itemBuilder: (context, index) {
          final category = _allCategories[index];
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () => _filterByCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                category,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: _filteredProducts[index],
          onAddToCart: (product) {
            Provider.of<CartProvider>(context, listen: false).addToCart({
              'id': product.id,
              'name': product.name,
              'price': product.price,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${product.name} added to cart',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
                backgroundColor: AppTheme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
