import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'tagline': 'WELLNESS STARTS HERE',
      'title': 'Your Health, Our Priority',
      'description': 'Premium supplements and vitamins, all in one place.',
      'bg': const Color(0xFFE8F5E9),
      'tagBg': const Color(0xFF43A047),
      'tagColor': const Color(0xFF43A047),
      'mainColor': const Color(0xFF43A047),
    },
    {
      'tagline': 'FAST DELIVERY',
      'title': 'Delivered to Your Door',
      'description': 'Your location, your method. We deliver.',
      'bg': const Color(0xFFF1F8E9),
      'tagBg': const Color(0xFF2E7D32),
      'tagColor': const Color(0xFF2E7D32),
      'mainColor': const Color(0xFF2E7D32),
    },
    {
      'tagline': 'TRUSTED PRODUCTS',
      'title': 'Quality You Can Count On',
      'description': 'Verified suppliers. Guaranteed quality.',
      'bg': const Color(0xFFE0F2F1),
      'tagBg': const Color(0xFF388E3C),
      'tagColor': const Color(0xFF388E3C),
      'mainColor': const Color(0xFF388E3C),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
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
    final double width = MediaQuery.of(context).size.width;
    final Map<String, dynamic> currentData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: currentData['bg'],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header with Logo and Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LogoLockup(),
                  TextButton(
                    onPressed: _goToLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: currentData['mainColor'],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Center(
                            child: _buildIllustration(index, width - 56),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Expanded(
                          flex: 4,
                          child: _buildContent(_pages[index]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Controls
            _buildBottomControls(currentData),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(int index, double width) {
    return Container(
      width: width * 0.7,
      height: width * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _pages[index]['mainColor'].withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.35),
          child: Image.asset(
            'assets/logo.png',
            width: width * 0.5,
            height: width * 0.5,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: data['tagBg'].withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            data['tagline'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: data['tagColor'],
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          data['title'],
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2E1C),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          data['description'],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF4E5D4F),
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dots
              Row(
                children: List.generate(_pages.length, (i) {
                  final bool active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? data['mainColor']
                          : data['mainColor'].withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              // Next Button
              GestureDetector(
                onTap: _goNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == _pages.length - 1 ? 140 : 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: data['mainColor'],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: data['mainColor'].withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _currentPage == _pages.length - 1
                        ? Text(
                            'Get Started',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
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

class _LogoLockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}


