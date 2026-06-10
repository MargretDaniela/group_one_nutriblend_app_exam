import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../services/product_service.dart';
import '../utils/theme.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/reusable_widgets.dart';
import 'main_screen.dart';
import 'wishlist_screen.dart';


// ─── Hero slide data ──────────────────────────────────────────────────────────

class _HeroSlide {
  final String imageUrl;
  final String badge;
  final String headline;
  final String sub;
  final Color tintStart;
  final Color tintEnd;

  const _HeroSlide({
    required this.imageUrl,
    required this.badge,
    required this.headline,
    required this.sub,
    required this.tintStart,
    required this.tintEnd,
  });
}

const _heroSlides = [
  _HeroSlide(
    imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=900&q=80',
    badge: 'NEW ARRIVALS',
    headline: 'Premium Supplements\nFor Peak Performance',
    sub: 'Shop Now',
    tintStart: Color(0xFF007A33),
    tintEnd: Color(0xFF2E7D32),
  ),
  _HeroSlide(
    imageUrl: 'https://images.unsplash.com/photo-1579722820308-d74e571900a9?w=900&q=80',
    badge: 'BESTSELLERS',
    headline: 'Natural Vitamins\nFor Daily Wellness',
    sub: 'Explore',
    tintStart: Color(0xFF1B5E20),
    tintEnd: Color(0xFF43A047),
  ),
  _HeroSlide(
    imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900&q=80',
    badge: 'ORGANIC RANGE',
    headline: 'Pure & Certified\nOrganic Nutrition',
    sub: 'Discover',
    tintStart: Color(0xFF004D40),
    tintEnd: Color(0xFF00BFA5),
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  int _heroIndex = 0;
  late PageController _heroController;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _heroController = PageController();
    _startHeroTimer();
    _loadCategories();
    _loadPage(1);
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startHeroTimer() {
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_heroIndex + 1) % _heroSlides.length;
      _heroController.animateToPage(next,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    });
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
        page: page, perPage: 12,
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
  void _goToCart() => context.findAncestorStateOfType<MainScreenState>()?.switchTab(2);

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
                  _buildHeroCarousel(),
                  const SizedBox(height: 20),
                  // Search bar with green styling
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: SearchBarWidget(
                      controller: _searchController,
                      onSearch: _doSearch,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryRow(),
                  const SizedBox(height: 24),
                  // Quick stats / promo banner
                  _buildPromoBanner(),
                  const SizedBox(height: 24),
                  if (_products.isNotEmpty && !_isLoading) ...[
                    _sectionHeader('Featured',
                        onSeeAll: () => context
                            .findAncestorStateOfType<MainScreenState>()
                            ?.switchTab(1)),
                    const SizedBox(height: 14),
                    _buildFeaturedScroll(),
                    const SizedBox(height: 24),
                  ],
                  _sectionHeader(
                    'All Products',
                    trailing: _lastPage > 1
                        ? Text('Page $_currentPage of $_lastPage',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12, color: AppTheme.textSecondary))
                        : null,
                  ),
                  const SizedBox(height: 14),
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
      // Green gradient app bar instead of plain white
      backgroundColor: AppTheme.primaryColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_florist_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('NutriBlend',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Premium Supplements',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10, color: Colors.white70)),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: cart.cart.isEmpty ? null : _goToCart,
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
              if (cart.cartCount > 0)
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
                        cart.cartCount > 9 ? '9+' : '${cart.cartCount}',
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
        const SizedBox(width: 10),
      ],
    );
  }


  Widget _buildHeroCarousel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: SizedBox(
        height: 228,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: PageView.builder(
                controller: _heroController,
                itemCount: _heroSlides.length,
                onPageChanged: (i) => setState(() => _heroIndex = i),
                itemBuilder: (_, i) => _HeroSlideWidget(
                  slide: _heroSlides[i],
                  onShopNow: () => _selectCategory(null),
                ),
              ),
            ),
            Positioned(
              bottom: 14, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_heroSlides.length, (i) {
                  final active = i == _heroIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 40,
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  gradient: sel
                      ? const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                          begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: sel ? null : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: sel ? Colors.transparent : AppTheme.primaryLight,
                    width: 1.5,
                  ),
                  boxShadow: sel
                      ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.35),
                            blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(cat['name'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      color: sel ? Colors.white : AppTheme.primaryDark,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    )),
              ),
            ),
          );
        },
      ),
    );
  }

  // Promo banner replacing the bland gap between categories and featured
  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Free Delivery',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('On orders above UGX 50,000',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.white.withOpacity(0.9))),
                ],
              ),
            ),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.local_shipping_outlined, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('See all',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
              ),
            )
          else if (trailing != null)
            trailing,
        ],
      ),
    );
  }

  Widget _buildFeaturedScroll() {
    final featured = _products.take(6).toList();
    return SizedBox(
      height: 255,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: featured.length,
        itemBuilder: (_, i) => SizedBox(
          width: 152,
          child: ProductGridCard(
            product: featured[i] as Map<String, dynamic>,
            isFeatured: true,
          ),
        ),
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
            (_, __) => _ShimmerCard(),
            childCount: 6,
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
          (_, i) => ProductGridCard(product: _products[i] as Map<String, dynamic>),
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
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: active ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              color: active ? Colors.white : Colors.grey.shade400, size: 22),
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
                style: GoogleFonts.plusJakartaSans(
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

// ─── Hero slide widget ────────────────────────────────────────────────────────

class _HeroSlideWidget extends StatelessWidget {
  final _HeroSlide slide;
  final VoidCallback onShopNow;
  const _HeroSlideWidget({required this.slide, required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(slide.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: slide.tintStart)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight, end: Alignment.bottomLeft,
              colors: [
                slide.tintStart.withOpacity(0.55),
                slide.tintEnd.withOpacity(0.88),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Text(slide.badge,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 10,
                        fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slide.headline,
                      style: GoogleFonts.playfairDisplay(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w800, height: 1.25)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: onShopNow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(slide.sub,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}


