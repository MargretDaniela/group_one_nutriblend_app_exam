

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './on_boarding_screen_three.dart';

class OnboardingScreenTwo extends StatefulWidget {
  const OnboardingScreenTwo({super.key});

  @override
  State<OnboardingScreenTwo> createState() => _OnboardingScreenTwoState();
}

class _OnboardingScreenTwoState extends State<OnboardingScreenTwo>
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

  void _goNext() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreenThree(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _LogoLockup(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 5,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) => Transform.scale(
                          scale: _illustrationScale.value,
                          child: _Illustration(width: width - 56),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      flex: 4,
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
                  ],
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
            color: const Color(0xFF2E7D32).withOpacity(0.11),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'FAST DELIVERY',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2E7D32),
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Delivered to\nYour Door',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2E1C),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your location, your method. We deliver.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF4E5D4F),
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildBottom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        children: [
          _Dots(current: 1),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Text(
                  'Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _goNext,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
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
                ? const Color(0xFF2E7D32)
                : const Color(0xFF2E7D32).withOpacity(0.25),
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