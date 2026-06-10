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

class _IllustrationOne extends StatelessWidget {
  final double width;
  const _IllustrationOne({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width * 0.82,
              height: width * 0.82,
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.64,
              height: width * 0.64,
              decoration: BoxDecoration(
                color: const Color(0xFFA5D6A7).withOpacity(0.42),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.54,
              height: width * 0.54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF43A047).withOpacity(0.28),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CustomPaint(painter: _LeafPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final fill = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;

    final soft = Paint()
      ..color = Colors.white.withOpacity(0.40)
      ..style = PaintingStyle.fill;

    final stem = Paint()
      ..color = Colors.white.withOpacity(0.88)
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leaf = Path()
      ..moveTo(cx, cy - size.height * 0.28)
      ..quadraticBezierTo(
          cx + size.width * 0.25, cy - size.height * 0.06,
          cx, cy + size.height * 0.14)
      ..quadraticBezierTo(
          cx - size.width * 0.25, cy - size.height * 0.06,
          cx, cy - size.height * 0.28);
    canvas.drawPath(leaf, fill);

    final leaf2 = Path()
      ..moveTo(cx - size.width * 0.06, cy + size.height * 0.06)
      ..quadraticBezierTo(
          cx + size.width * 0.17, cy + size.height * 0.21,
          cx - size.width * 0.01, cy + size.height * 0.33)
      ..quadraticBezierTo(
          cx - size.width * 0.22, cy + size.height * 0.21,
          cx - size.width * 0.06, cy + size.height * 0.06);
    canvas.drawPath(leaf2, soft);

    canvas.drawLine(
      Offset(cx, cy + size.height * 0.10),
      Offset(cx, cy + size.height * 0.36),
      stem,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _IllustrationTwo extends StatelessWidget {
  final double width;
  const _IllustrationTwo({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width * 0.82,
              height: width * 0.82,
              decoration: BoxDecoration(
                color: const Color(0xFFC5E1A5).withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.64,
              height: width * 0.64,
              decoration: BoxDecoration(
                color: const Color(0xFFC5E1A5).withOpacity(0.42),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.54,
              height: width * 0.54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.28),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CustomPaint(painter: _DeliveryPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final boxFill = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.45)
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = Colors.white.withOpacity(0.88)
      ..strokeWidth = size.width * 0.048
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - size.height * 0.06),
        width: size.width * 0.50,
        height: size.height * 0.36,
      ),
      Radius.circular(size.width * 0.09),
    );
    canvas.drawRRect(rrect, boxFill);

    final lx = cx - size.width * 0.15;
    final ly = cy - size.height * 0.13;
    canvas.drawLine(
        Offset(lx, ly), Offset(lx + size.width * 0.30, ly), linePaint);
    canvas.drawLine(
      Offset(lx, ly + size.height * 0.07),
      Offset(lx + size.width * 0.20, ly + size.height * 0.07),
      linePaint,
    );

    final arrow = Path()
      ..moveTo(cx - size.width * 0.13, cy + size.height * 0.24)
      ..lineTo(cx + size.width * 0.13, cy + size.height * 0.24)
      ..moveTo(cx + size.width * 0.03, cy + size.height * 0.14)
      ..lineTo(cx + size.width * 0.13, cy + size.height * 0.24)
      ..lineTo(cx + size.width * 0.03, cy + size.height * 0.34);
    canvas.drawPath(arrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _IllustrationThree extends StatelessWidget {
  final double width;
  const _IllustrationThree({required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width * 0.82,
              height: width * 0.82,
              decoration: BoxDecoration(
                color: const Color(0xFF80CBC4).withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.64,
              height: width * 0.64,
              decoration: BoxDecoration(
                color: const Color(0xFF80CBC4).withOpacity(0.42),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: width * 0.54,
              height: width * 0.54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF388E3C).withOpacity(0.28),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CustomPaint(painter: _ShieldPainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final shieldFill = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.fill;

    final checkPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = size.width * 0.058
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final shield = Path()
      ..moveTo(cx, cy - size.height * 0.30)
      ..lineTo(cx + size.width * 0.26, cy - size.height * 0.17)
      ..lineTo(cx + size.width * 0.26, cy + size.height * 0.03)
      ..quadraticBezierTo(
          cx + size.width * 0.26,
          cy + size.height * 0.20,
          cx,
          cy + size.height * 0.30)
      ..quadraticBezierTo(
          cx - size.width * 0.26,
          cy + size.height * 0.20,
          cx - size.width * 0.26,
          cy + size.height * 0.03)
      ..lineTo(cx - size.width * 0.26, cy - size.height * 0.17)
      ..close();
    canvas.drawPath(shield, shieldFill);

    final check = Path()
      ..moveTo(cx - size.width * 0.11, cy + size.height * 0.00)
      ..lineTo(cx - size.width * 0.01, cy + size.height * 0.11)
      ..lineTo(cx + size.width * 0.13, cy - size.height * 0.09);
    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
