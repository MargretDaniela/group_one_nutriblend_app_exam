import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './on_boarding_screen_one.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _logoController;
  late AnimationController _textController;

  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _ringScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOutBack),
    );
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _ringController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 350));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreenOne(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogoStack(),
            const SizedBox(height: 30),
            _buildWordmark(),
            const SizedBox(height: 56),
            _buildLoader(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoStack() {
    return AnimatedBuilder(
      animation: Listenable.merge([_ringController, _logoController]),
      builder: (_, __) {
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: _ringOpacity.value,
                child: Transform.scale(
                  scale: _ringScale.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF66BB6A).withOpacity(0.22),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _ringOpacity.value,
                child: Transform.scale(
                  scale: _ringScale.value * 0.84,
                  child: Container(
                    width: 135,
                    height: 135,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF66BB6A).withOpacity(0.14),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: const _AppLogo(size: 96),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordmark() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (_, __) {
        return FadeTransition(
          opacity: _textOpacity,
          child: SlideTransition(
            position: _textSlide,
            child: Column(
              children: [
                Text(
                  'NutriBlend',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E20),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'HEALTH & NUTRITION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                    letterSpacing: 3.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (_, __) {
        return FadeTransition(
          opacity: _textOpacity,
          child: SizedBox(
            width: 40,
            height: 3,
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.18),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}

class _AppLogo extends StatelessWidget {
  final double size;
  const _AppLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.38),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final fill = Paint()
      ..color = Colors.white.withOpacity(0.92)
      ..style = PaintingStyle.fill;

    final soft = Paint()
      ..color = Colors.white.withOpacity(0.38)
      ..style = PaintingStyle.fill;

    final stem = Paint()
      ..color = Colors.white.withOpacity(0.88)
      ..strokeWidth = size.width * 0.048
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leaf = Path()
      ..moveTo(cx, cy - size.height * 0.27)
      ..quadraticBezierTo(
          cx + size.width * 0.24, cy - size.height * 0.06,
          cx, cy + size.height * 0.13)
      ..quadraticBezierTo(
          cx - size.width * 0.24, cy - size.height * 0.06,
          cx, cy - size.height * 0.27);
    canvas.drawPath(leaf, fill);

    final leaf2 = Path()
      ..moveTo(cx - size.width * 0.06, cy + size.height * 0.06)
      ..quadraticBezierTo(
          cx + size.width * 0.16, cy + size.height * 0.20,
          cx - size.width * 0.01, cy + size.height * 0.32)
      ..quadraticBezierTo(
          cx - size.width * 0.22, cy + size.height * 0.20,
          cx - size.width * 0.06, cy + size.height * 0.06);
    canvas.drawPath(leaf2, soft);

    canvas.drawLine(
      Offset(cx, cy + size.height * 0.10),
      Offset(cx, cy + size.height * 0.35),
      stem,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}