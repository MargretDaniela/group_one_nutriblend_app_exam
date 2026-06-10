

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreenThree extends StatefulWidget {
  const OnboardingScreenThree({super.key});

  @override
  State<OnboardingScreenThree> createState() => _OnboardingScreenThreeState();
}

class _OnboardingScreenThreeState extends State<OnboardingScreenThree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _illustrationScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _illustrationScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _LogoLockup(),
            ),
            // Illustration — fixed height based on screen
            SizedBox(
              height: height * 0.38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => Transform.scale(
                    scale: _illustrationScale.value,
                    child: _Illustration(width: width - 56),
                  ),
                ),
              ),
            ),
            // Content + bottom — scrollable so it never overflows
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ),
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF388E3C).withOpacity(0.11),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'TRUSTED PRODUCTS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF388E3C),
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Quality You Can Count On',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2E1C),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Verified suppliers. Guaranteed quality.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF4E5D4F),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        children: [
          _Dots(current: 2),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _goBack,
            child: Text(
              'Back',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final double width;
  const _Illustration({required this.width});

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

class _Dots extends StatelessWidget {
  final int current;
  const _Dots({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final bool active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF388E3C)
                : const Color(0xFF388E3C).withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _LogoLockup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          'NutriBlend',
          style: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }
}