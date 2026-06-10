import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/product_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'wishlist_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [
    {'id': null, 'name': 'All'}
  ];
  int? _selectedCategoryId;
  bool _catsLoaded = false;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadPage(1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (_catsLoaded) return;
    try {
      final res = await ProductService.fetchProducts(perPage: 100);
      final all = res['products'] as List;
      final seen = <int>{};
      final cats = <Map<String, dynamic>>[
        {'id': null, 'name': 'All'}
      ];
      for (final p in all) {
        final cat = p['category'];
        if (cat != null) {
          final id = cat['id'] as int;
          if (seen.add(id)) cats.add({'id': id, 'name': cat['name']});
        }
      }
      cats.sort((a, b) => a['name'] == 'All'
          ? -1
          : (a['name'] as String).compareTo(b['name'] as String));
      if (mounted) {
        setState(() {
          _categories = cats;
          _catsLoaded = true;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading && page != 1) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res = await ProductService.fetchProducts(
        page: page,
        perPage: 12,
        search: _search,
        categoryId: _selectedCategoryId,
      );
      if (!mounted) return;
      setState(() {
        _products = res['products'] as List;
        _currentPage = page;
        _lastPage = res['lastPage'] as int;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load products. Check your connection.';
        _isLoading = false;
      });
    }
  }

  void _doSearch(String v) {
    setState(() => _search = v);
    _loadPage(1);
  }

  void _selectCategory(int? id) {
    setState(() => _selectedCategoryId = id);
    _loadPage(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildCategoryRow(),
                const SizedBox(height: 16),
                _buildSectionHeader(
                  'All Products',
                  trailing: _lastPage > 1
                      ? Text(
                          'Page $_currentPage of $_lastPage',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _buildProductsSliver(),
          if (_products.isNotEmpty && !_isLoading && _lastPage > 1)
            SliverToBoxAdapter(child: _buildPagination()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Products',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<WishlistProvider>(
          builder: (context, wishlist, _) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
                },
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
              if (wishlist.count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        wishlist.count > 9 ? '9+' : '${wishlist.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            _loadCategories();
            _loadPage(1);
          },
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _doSearch,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search supplements...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (_search.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _doSearch('');
                },
                child: Icon(Icons.close_rounded,
                    color: Colors.grey.shade400, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final sel = _selectedCategoryId == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectCategory(cat['id'] as int?),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: sel ? AppTheme.primaryColor : Colors.grey.shade200,
                    width: sel ? 0 : 1,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  cat['name'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    color: sel ? Colors.white : Colors.black87,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildProductsSliver() {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, __) => _ShimmerCard(),
            childCount: 6,
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: _ErrorView(
          message: _error!,
          onRetry: () => _loadPage(_currentPage),
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 36,
                  color: AppTheme.primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              if (_search.isNotEmpty || _selectedCategoryId != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _search = '';
                      _selectedCategoryId = null;
                    });
                    _loadPage(1);
                  },
                  child: Text(
                    'Clear filters',
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

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: _products[i]),
              ),
            ),
            child: ProductGridCard(product: _products[i]),
          ),
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn(
            Icons.chevron_left,
            _currentPage > 1 ? () => _loadPage(_currentPage - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '$_currentPage / $_lastPage',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          _pageBtn(
            Icons.chevron_right,
            _currentPage < _lastPage
                ? () => _loadPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _pageBtn(IconData icon, VoidCallback? onTap) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: active ? Colors.white : Colors.grey.shade400,
          size: 22,
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 36, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Try Again',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
