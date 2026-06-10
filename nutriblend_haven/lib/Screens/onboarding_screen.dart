import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

// ─── Onboarding data ──────────────────────────────────────────────────────────

class _OBData {
  final String tagline;
  final String headline;
  final String body;
  final Color bgColor;
  final Color shapeColor;
  final IconData icon;

  const _OBData({
    required this.tagline,
    required this.headline,
    required this.body,
    required this.bgColor,
    required this.shapeColor,
    required this.icon,
  });
}

const _pages = [
  _OBData(
    tagline: 'WELLNESS FIRST',
    headline: 'Your health,\nour priority.',
    body: 'Premium supplements and vitamins curated for peak performance and daily wellbeing.',
    bgColor: Color(0xFF00A651),
    shapeColor: Color(0xFF007A3D),
    icon: Icons.eco_rounded,
  ),
  _OBData(
    tagline: 'FAST DELIVERY',
    headline: 'Delivered right\nto your door.',
    body: 'Express shipping nationwide. Track your order in real time from checkout to doorstep.',
    bgColor: Color(0xFF0D1F14),
    shapeColor: Color(0xFF00A651),
    icon: Icons.local_shipping_outlined,
  ),
  _OBData(
    tagline: 'TRUSTED QUALITY',
    headline: 'Certified pure,\nguaranteed.',
    body: 'Every product is lab-tested and sourced from verified suppliers you can trust.',
    bgColor: Color(0xFFF7F8F7),
    shapeColor: Color(0xFF00A651),
    icon: Icons.verified_outlined,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryFade = CurvedAnimation(parent: _entryController, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentPage = i);
    _entryController.reset();
    _entryController.forward();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.bgColor,
      body: Column(
        children: [
          // Top half — illustration area with PageView
          Expanded(
            flex: 5,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final p = _pages[index];
                final dark = p.bgColor.computeLuminance() < 0.3;
                return Stack(
                  children: [
                    // Large background shape
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BlobPainter(
                          color: p.shapeColor.withOpacity(dark ? 0.40 : 0.12),
                        ),
                      ),
                    ),
                    // Center icon illustration
                    Center(
                      child: _IllustrationBubble(
                        icon: p.icon,
                        bgColor: p.shapeColor,
                        isDark: dark,
                      ),
                    ),
                    // Skip button top-right
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, top: 8),
                          child: TextButton(
                            onPressed: _goToLogin,
                            style: TextButton.styleFrom(
                              foregroundColor: dark
                                  ? Colors.white.withOpacity(0.65)
                                  : const Color(0xFF6B7B70),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Bottom panel — white card
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(28, 32, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scrollable text content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tagline
                            FadeTransition(
                              opacity: _entryFade,
                              child: SlideTransition(
                                position: _entrySlide,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00A651).withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    page.tagline,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00A651),
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Headline
                            FadeTransition(
                              opacity: _entryFade,
                              child: SlideTransition(
                                position: _entrySlide,
                                child: Text(
                                  page.headline,
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 32,
                                    color: const Color(0xFF0D1F14),
                                    height: 1.15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Body
                            FadeTransition(
                              opacity: _entryFade,
                              child: SlideTransition(
                                position: _entrySlide,
                                child: Text(
                                  page.body,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7B70),
                                    height: 1.65,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Dots + Button row (pinned at bottom)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Page dots
                          Row(
                            children: List.generate(_pages.length, (i) {
                              final active = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: active ? 24 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF00A651)
                                      : const Color(0xFFCED4DA),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          // CTA button
                          GestureDetector(
                            onTap: _goNext,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 56,
                              width: _currentPage == _pages.length - 1
                                  ? 160
                                  : 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A651),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00A651)
                                        .withOpacity(0.30),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _currentPage == _pages.length - 1
                                    ? Text(
                                        'Get Started',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

// ─── Illustration bubble ─────────────────────────────────────────────────────

class _IllustrationBubble extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final bool isDark;

  const _IllustrationBubble({
    required this.icon,
    required this.bgColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : bgColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.18) : bgColor,
            shape: BoxShape.circle,
          ),
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Background blob painter ──────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  final Color color;
  const _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.85,
      size.width * 0.45, size.height * 0.72,
    );
    path.quadraticBezierTo(
      size.width * 0.15, size.height * 0.60,
      size.width * 0.0, size.height * 0.50,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.color != color;
}
