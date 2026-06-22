import 'package:flutter/material.dart';

class QiblahArrowPainter extends CustomPainter {
  const QiblahArrowPainter({
    required this.primaryColor,
    required this.primaryColorDark,
  });

  final Color primaryColor;
  final Color primaryColorDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    _drawMainArrow(canvas, size, center);
    _drawHighlights(canvas, size, center);
  }

  void _drawMainArrow(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [primaryColor.withAlpha(229), primaryColorDark.withAlpha(204)],
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.4)
      ..lineTo(center.dx - 12, center.dy - size.height * 0.1)
      ..lineTo(center.dx + 12, center.dy - size.height * 0.1)
      ..close()
      ..addRect(Rect.fromPoints(
        Offset(center.dx - 8, center.dy - size.height * 0.1),
        Offset(center.dx + 8, center.dy + size.height * 0.3),
      ));

    canvas.drawPath(path, paint);
  }

  void _drawHighlights(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - size.height * 0.35)
        ..lineTo(center.dx - 8, center.dy - size.height * 0.15)
        ..moveTo(center.dx, center.dy - size.height * 0.35)
        ..lineTo(center.dx + 8, center.dy - size.height * 0.15)
        ..moveTo(center.dx - 8, center.dy - size.height * 0.1)
        ..lineTo(center.dx - 4, center.dy + size.height * 0.25)
        ..moveTo(center.dx + 8, center.dy - size.height * 0.1)
        ..lineTo(center.dx + 4, center.dy + size.height * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant QiblahArrowPainter old) =>
      old.primaryColor != primaryColor;
}
