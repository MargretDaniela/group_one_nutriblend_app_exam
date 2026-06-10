import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/product_service.dart';
import '../utils/theme.dart';
import 'wishlist_screen.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/reusable_widgets.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  List<Map<String, dynamic>> _categories = [
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
      if (mounted) setState(() { _categories = cats; _catsLoaded = true; });
    } catch (_) {}
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading && page != 1) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ProductService.fetchProducts(
        page: page, perPage: 16,
        search: _search, categoryId: _selectedCategoryId,
      );
      if (!mounted) return;
      setState(() {
        _products = res['products'] as List;
        _currentPage = page;
        _lastPage = res['lastPage'] as int;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load products. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    _catsLoaded = false;
    await Future.wait([_loadCategories(), _loadPage(1)]);
  }

  void _doSearch(String v) { setState(() => _search = v); _loadPage(1); }
  void _selectCategory(int? id) { setState(() => _selectedCategoryId = id); _loadPage(1); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        strokeWidth: 2.5,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SearchBarWidget(
                      controller: _searchController,
                      onSearch: _doSearch,
                      hintText: 'Search supplements…',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryRow(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isLoading ? 'Loading…' : '${_products.length} products',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        if (_lastPage > 1 && !_isLoading)
                          Text('Page $_currentPage of $_lastPage',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
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
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text('Shop',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark)),
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
                    color: const Color(0xFFF7F8F7),
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
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppTheme.divider),
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
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: sel
                      ? const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)
                      : null,
                  color: sel ? null : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: sel ? Colors.transparent : AppTheme.divider),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child: Text(cat['name'] as String,
                    style: GoogleFonts.inter(
                      color: sel ? Colors.white : AppTheme.textPrimary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSliver() {
    if (_isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.65),
          delegate: SliverChildBuilderDelegate(
            (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 55,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 45,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 12, width: 80, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(height: 12, width: double.infinity, color: Colors.white),
                            const SizedBox(height: 4),
                            Container(height: 12, width: 50, color: Colors.white),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(height: 16, width: 40, color: Colors.white),
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            childCount: 8,
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: ErrorView(
          message: _error!,
          onRetry: () => _loadPage(_currentPage),
        ),
      );
    }

    if (_products.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.search_off_rounded,
          title: 'No products found',
          subtitle: 'Try a different search or category.',
          actionLabel: (_search.isNotEmpty || _selectedCategoryId != null)
              ? 'Clear filters'
              : null,
          onAction: () {
            _searchController.clear();
            setState(() { _search = ''; _selectedCategoryId = null; });
            _loadPage(1);
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.65),
        delegate: SliverChildBuilderDelegate(
          (_, i) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: _products[i]),
              ),
            ),
            child: ProductGridCard(
              product: _products[i] as Map<String, dynamic>),
          ),
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    Widget btn(IconData icon, VoidCallback? onTap) {
      final active = onTap != null;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
            color: active ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              color: active ? Colors.white : Colors.grey.shade400,
              size: 22),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          btn(Icons.chevron_left,
              _currentPage > 1 ? () => _loadPage(_currentPage - 1) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$_currentPage / $_lastPage',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
          ),
          btn(Icons.chevron_right,
              _currentPage < _lastPage
                  ? () => _loadPage(_currentPage + 1)
                  : null),
        ],
      ),
    );
  }
}
