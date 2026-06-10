

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './on_boarding_screen_two.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne>
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
        pageBuilder: (_, __, ___) => const OnboardingScreenTwo(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
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
            color: const Color(0xFF43A047).withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'WELLNESS STARTS HERE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF43A047),
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your Health, Our Priority',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B2E1C),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Premium supplements and vitamins, all in one place.',
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
          _Dots(current: 0),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _goNext,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF43A047).withOpacity(0.35),
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
                ? const Color(0xFF43A047)
                : const Color(0xFF43A047).withOpacity(0.25),
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