import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Guest User';
  String _email = '';
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? 'Guest User';
      _email = prefs.getString('user_email') ?? '';
      _loadingUser = false;
    });
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return _name.isNotEmpty ? _name[0].toUpperCase() : 'G';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final wl = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: CustomScrollView(
        slivers: [
          // Header takes up the top with green gradient
          SliverToBoxAdapter(child: _buildHeader()),
          // Stats card sits BELOW header, no overlap tricks needed
          SliverToBoxAdapter(child: _buildStats(cart.cartCount, wl.count)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('ACCOUNT', [
                    _Item(
                      icon: Icons.receipt_long_outlined,
                      color: AppTheme.primaryDark,
                      bg: AppTheme.accent,
                      title: 'Order History',
                    ),
                    _Item(
                      icon: Icons.location_on_outlined,
                      color: const Color(0xFF1565C0),
                      bg: const Color(0xFFE3F2FD),
                      title: 'Saved Addresses',
                    ),
                    _Item(
                      icon: Icons.payment_outlined,
                      color: const Color(0xFF6A1B9A),
                      bg: const Color(0xFFF3E5F5),
                      title: 'Payment Methods',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('PREFERENCES', [
                    _Item(
                      icon: Icons.notifications_outlined,
                      color: const Color(0xFFE65100),
                      bg: const Color(0xFFFFF3E0),
                      title: 'Notifications',
                    ),
                    _Item(
                      icon: Icons.lock_outline_rounded,
                      color: AppTheme.primaryColor,
                      bg: AppTheme.accent,
                      title: 'Security',
                    ),
                    _Item(
                      icon: Icons.dark_mode_outlined,
                      color: const Color(0xFF283593),
                      bg: const Color(0xFFE8EAF6),
                      title: 'Appearance',
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSection('SUPPORT', [
                    _Item(
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xFF00838F),
                      bg: const Color(0xFFE0F7FA),
                      title: 'Help & Support',
                    ),
                    _Item(
                      icon: Icons.star_outline_rounded,
                      color: const Color(0xFFF9A825),
                      bg: const Color(0xFFFFFDE7),
                      title: 'Rate NutriBlend',
                    ),
                    _Item(
                      icon: Icons.info_outline_rounded,
                      color: AppTheme.textSecondary,
                      bg: const Color(0xFFEFEBE9),
                      title: 'About',
                    ),
                  ]),
                  const SizedBox(height: 28),
                  _buildLogoutButton(auth),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // Bright vivid green gradient top-to-bottom
          colors: [AppTheme.primaryDark, AppTheme.primaryColor, Color(0xFF00E676)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Profile',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Avatar + user info row
              Row(
                children: [
                  // Avatar circle with initials
                  Container(
                    width: 76, height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: _loadingUser
                        ? const SizedBox()
                        : Center(
                            child: Text(_initials,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 26, fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        if (_email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_email,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13, color: Colors.white.withOpacity(0.85))),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 5),
                              Text('Verified Member',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11, fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(int cartCount, int wishlistCount) {
    // Clean card below the header — no negative margin overlap
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _stat('Orders', '0', Icons.receipt_long_outlined, AppTheme.primaryColor, AppTheme.accent),
          _statDivider(),
          _stat('Wishlist', '$wishlistCount', Icons.favorite_border_rounded,
              const Color(0xFFE53935), const Color(0xFFFFEBEE)),
          _statDivider(),
          _stat('Cart', '$cartCount', Icons.shopping_bag_outlined,
              const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 44, color: AppTheme.divider);

  Widget _buildSection(String label, List<_Item> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: item.onTap ?? () {},
                    borderRadius: BorderRadius.only(
                      topLeft: i == 0 ? const Radius.circular(16) : Radius.zero,
                      topRight: i == 0 ? const Radius.circular(16) : Radius.zero,
                      bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                                color: item.bg, borderRadius: BorderRadius.circular(12)),
                            child: Icon(item.icon, color: item.color, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.title,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary)),
                          ),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.scaffold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.chevron_right_rounded,
                                color: AppTheme.primaryColor, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 70, endIndent: 16, color: AppTheme.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Log Out',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
              content: Text('Are you sure you want to log out?',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Log Out',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await auth.logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text('Log Out',
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final VoidCallback? onTap;
  const _Item({required this.icon, required this.color, required this.bg, required this.title, this.onTap});
}
