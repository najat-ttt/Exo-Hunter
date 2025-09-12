import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CosmicBackground extends StatelessWidget {
  final Widget child;
  final bool showStars;

  const CosmicBackground({
    super.key,
    required this.child,
    this.showStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.midnightBlue,
            AppTheme.midnightBlue.withAlpha((0.8 * 255).toInt()),
            Colors.black.withAlpha((0.9 * 255).toInt()),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cosmic background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cosmic_bg.png'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),

          // Stars overlay (if enabled)
          if (showStars) const StarsOverlay(),

          // Dark overlay for better readability
          Container(
            decoration: BoxDecoration(
              color: AppTheme.midnightBlue.withAlpha((0.7 * 255).toInt()),
            ),
          ),

          // Main content
          child,
        ],
      ),
    );
  }
}

class StarsOverlay extends StatefulWidget {
  const StarsOverlay({super.key});

  @override
  State<StarsOverlay> createState() => _StarsOverlayState();
}

class _StarsOverlayState extends State<StarsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarsPainter(_animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class StarsPainter extends CustomPainter {
  final double opacity;

  StarsPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((opacity * 0.8 * 255).toInt())
      ..strokeWidth = 1;

    // Generate some random-looking stars
    final stars = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.1),
    ];

    for (final star in stars) {
      canvas.drawCircle(star, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}