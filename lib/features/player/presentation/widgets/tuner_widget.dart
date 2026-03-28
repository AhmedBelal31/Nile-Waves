import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TunerWidget extends StatelessWidget {
  final double currentFreq;
  const TunerWidget({super.key, required this.currentFreq});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: CustomPaint(
        painter: _TunerPainter(
          currentFreq: currentFreq,
          accentColor: AppTheme.primary,
          tickColor: AppTheme.textSecondary.withValues(alpha: 0.3),
          textColor: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _TunerPainter extends CustomPainter {
  final double currentFreq;
  final Color accentColor;
  final Color tickColor;
  final Color textColor;

  _TunerPainter({
    required this.currentFreq,
    required this.accentColor,
    required this.tickColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final textStyle = TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold);

    // Range 88.0 to 108.0 (20 units).
    // Let's say map center (size.width/2) to currentFreq.
    // 1 Unit of freq = size.width / 10
    final range = 10.0; // Draw +/- 5 MHz
    final startFreq = (currentFreq - (range / 2)).floorToDouble();
    final endFreq = (currentFreq + (range / 2)).ceilToDouble();

    final pixelsPerFreq = size.width / range;

    for (double f = startFreq; f <= endFreq; f += 0.2) {
      // Calculate x position based on distance from currentFreq
      final x = (size.width / 2) + ((f - currentFreq) * pixelsPerFreq);
      
      // Don't draw outside bounds
      if (x < 0 || x > size.width) continue;

      bool isMajor = f % 2.0 == 0 || f % 2.0 == 1.0;
      bool isMedium = f * 10 % 10 == 0; // whole numbers
      
      double tickHeight = isMajor ? 30 : isMedium ? 20 : 10;
      
      // Draw tick
      canvas.drawLine(
        Offset(x, 20),
        Offset(x, 20 + tickHeight),
        tickPaint,
      );

      // Draw text for major
      if (isMajor) {
        final textSpan = TextSpan(text: f.toStringAsFixed(1), style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, 55));
      }
    }

    // Draw center red marker
    final centerX = size.width / 2;
    canvas.drawLine(
      Offset(centerX, 15),
      Offset(centerX, 60),
      accentPaint,
    );
    
    // Draw red triangle at bottom
    final path = Path()
      ..moveTo(centerX, 65)
      ..lineTo(centerX - 6, 75)
      ..lineTo(centerX + 6, 75)
      ..close();
      
    final fillPaint = Paint()..color = accentColor;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _TunerPainter oldDelegate) {
    return oldDelegate.currentFreq != currentFreq;
  }
}
