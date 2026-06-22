import 'dart:math';

import 'package:fazakir/Features/prayer_times/presentation/views/widgets/arrow_painter.dart';
import 'package:fazakir/Features/prayer_times/presentation/views/widgets/compass_background_painter.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class QiblahCompass extends StatelessWidget {
  const QiblahCompass({
    required this.headingAngle,
    required this.qiblahAngle,
    required this.isAligned,
    required this.isLoading,
    this.sensorAccuracy,
    super.key,
  });

  final double headingAngle;
  final double qiblahAngle;
  final bool isAligned;
  final bool isLoading;
  final double? sensorAccuracy;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text(
              'جاري تحميل البوصلة...',
              style: TextStyle(fontFamily: 'Almarai', fontSize: 16),
            ),
          ],
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final diameter = min(size.width * 0.8, 300.0);
    final compassSize = Size(diameter, diameter);
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          _buildMainCircle(compassSize, theme),
          _buildFixedArrow(),
          if (isAligned) _buildAlignedText(),
          _buildKaabaIcon(),
        ],
      ),
    );
  }

  Widget _buildMainCircle(Size compassSize, ThemeData theme) =>
      AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: compassSize.width,
        height: compassSize.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.cardColor,
          border: Border.all(
            color: isAligned
                ? AppColors.primaryColor
                : (sensorAccuracy != null && sensorAccuracy! > 45)
                    ? Colors.orange.withValues(alpha: 0.5)
                    : const Color(0xFFE0E0E0),
            width: isAligned ? 18.0 : 14.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: headingAngle,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(compassSize.width * 0.97, compassSize.height * 0.97),
                  painter: CompassBackgroundPainter(
                    primaryColor: AppColors.primaryColor,
                    surfaceColor: theme.colorScheme.surface,
                    onSurfaceColor: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: qiblahAngle,
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(
                    compassSize.width * 0.45,
                    compassSize.height * 0.85,
                  ),
                  painter: const QiblahArrowPainter(
                    primaryColor: AppColors.primaryColor,
                    primaryColorDark: Color(0xFF5A4832),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFixedArrow() => Positioned(
        top: -57,
        child: Icon(
          Icons.arrow_drop_up,
          size: 100,
          color: isAligned ? AppColors.primaryColor : const Color(0xFFBDBDBD),
        ),
      );

  Widget _buildAlignedText() => Positioned(
        bottom: -80,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Text(
            'اتجاه الصلاة',
            style: TextStyle(
              fontFamily: 'Almarai',
              color: Color(0xFF3D2E1A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );

  Widget _buildKaabaIcon() => Positioned(
        top: -100,
        child: ClipOval(
          child: Image.asset(
            'assets/images/kaaba.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.mosque_rounded,
              size: 80,
              color: Colors.green.shade700,
            ),
          ),
        ),
      );
}
