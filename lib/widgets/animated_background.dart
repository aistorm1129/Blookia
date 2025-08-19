import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _colorController;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _colorController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_controller);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF2563EB).withValues(alpha: 0.1),
      end: const Color(0xFF10B981).withValues(alpha: 0.1),
    ).animate(_colorController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_animation, _colorAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                _colorAnimation.value ?? Colors.transparent,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPainter(
              animation: _animation.value,
              color: _colorAnimation.value ?? Colors.transparent,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  final Color color;

  BackgroundPainter({
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw floating circles
    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.2 + 0.6 * math.sin(animation + i * 0.8));
      final y = size.height * (0.3 + 0.4 * math.cos(animation + i * 1.2));
      final radius = 20 + 30 * math.sin(animation * 2 + i);
      
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    // Draw wave-like shapes
    final wavePaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    
    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.8 + 
          50 * math.sin((x / size.width) * 2 * math.pi + animation * 2);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}