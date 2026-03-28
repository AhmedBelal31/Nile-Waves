import 'package:flutter/material.dart';

class BackgroundWavePainter extends CustomPainter {
  final Color color;

  BackgroundWavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Just an elegant static wave pattern
    final heights = [10.0, 20.0, 40.0, 30.0, 50.0, 70.0, 60.0, 40.0, 20.0, 30.0, 50.0, 100.0, 80.0, 60.0, 40.0, 20.0, 10.0];
    
    final space = size.width / heights.length;
    
    for (int i = 0; i < heights.length; i++) {
        final x = i * space;
        final h = heights[i];
        final startY = (size.height / 2) - (h / 2);
        final endY = (size.height / 2) + (h / 2);
        
        canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
