import 'dart:math';

import 'package:flutter/material.dart';

const double _toRad = pi / 180;

class CompassBackgroundPainter extends CustomPainter {
  const CompassBackgroundPainter({
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    _drawCircles(canvas, center, radius);
    _drawMarks(canvas, center, radius);
  }

  void _drawCircles(Canvas canvas, Offset center, double radius) {
    canvas
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = primaryColor.withAlpha(38)
          ..style = PaintingStyle.fill,
      )
      ..drawCircle(
        center,
        radius * 0.7,
        Paint()
          ..color = primaryColor.withAlpha(51)
          ..style = PaintingStyle.fill,
      )
      ..drawCircle(
        center,
        radius * 0.4,
        Paint()
          ..color = surfaceColor.withAlpha(229)
          ..style = PaintingStyle.fill,
      );
  }

  void _drawMarks(Canvas canvas, Offset center, double radius) {
    _drawSmallMarks(canvas, center, radius);
    _drawMainMarks(canvas, center, radius);
    _drawCardinalMarks(canvas, center, radius);
  }

  void _drawSmallMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = onSurfaceColor.withAlpha(153)
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * _toRad;
      final startRadius = i % 15 == 0 ? radius * 0.85 : radius * 0.9;
      canvas.drawLine(
        _point(center, startRadius, angle),
        _point(center, radius, angle),
        paint,
      );
    }
  }

  void _drawMainMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 15) {
      final angle = i * _toRad;
      canvas.drawLine(
        _point(center, radius * 0.8, angle),
        _point(center, radius * 0.95, angle),
        paint,
      );
    }
  }

  void _drawCardinalMarks(Canvas canvas, Offset center, double radius) {
    const cardinals = ['E', 'S', 'W', 'N'];
    final linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3;

    final tp = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 90) {
      final angle = i * _toRad;
      canvas.drawLine(
        _point(center, radius * 0.75, angle),
        _point(center, radius * 0.95, angle),
        linePaint,
      );

      tp.text = TextSpan(
        text: cardinals[i ~/ 90],
        style: TextStyle(
          color: primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + radius * 0.6 * cos(angle) - tp.width / 2,
          center.dy + radius * 0.6 * sin(angle) - tp.height / 2,
        ),
      );
    }
  }

  Offset _point(Offset center, double dist, double angle) =>
      Offset(center.dx + dist * cos(angle), center.dy + dist * sin(angle));

  @override
  bool shouldRepaint(covariant CompassBackgroundPainter old) =>
      old.primaryColor != primaryColor;
}
