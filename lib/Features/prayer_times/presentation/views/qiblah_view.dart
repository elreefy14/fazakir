import 'package:fazakir/Features/prayer_times/presentation/manager/cubits/qiblah_cubit/qiblah_cubit.dart';
import 'package:fazakir/Features/prayer_times/presentation/views/widgets/qiblah_compass.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class QiblahView extends StatelessWidget {
  const QiblahView({super.key});

  static const String routeName = 'qiblahView';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QiblahCubit()..init(),
      child: const _QiblahViewContent(),
    );
  }
}

class _QiblahViewContent extends StatelessWidget {
  const _QiblahViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'اتجاه القبلة',
          style: TextStyle(
            fontFamily: 'Almarai',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<QiblahCubit, QiblahState>(
          builder: (context, state) {
            if (state.status == QiblahStatus.error) {
              return _buildErrorState(context, state);
            } else if (state.status == QiblahStatus.success &&
                !state.hasMagnetometer) {
              return _buildFallbackState(context, state);
            } else {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildSuccessState(state),
                  if (state.isCalibrationNeeded) _buildCalibrationOverlay(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, QiblahState state) {
    final isPermissionError =
        state.message?.contains('الصلاحية') ?? false;
    final isLocationError =
        state.message?.contains('خدمة الموقع') ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPermissionError || isLocationError
                  ? Icons.location_off_rounded
                  : Icons.error_outline_rounded,
              size: 64,
              color: isPermissionError || isLocationError
                  ? AppColors.primaryColor
                  : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.message ?? 'حدث خطأ',
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isPermissionError) ...[
              ElevatedButton.icon(
                onPressed: () => Geolocator.openAppSettings(),
                icon: const Icon(Icons.settings),
                label: const Text(
                  'فتح الإعدادات',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: () => context.read<QiblahCubit>().retry(),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackState(BuildContext context, QiblahState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore_off_outlined,
              size: 80,
              color: AppColors.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'عذراً، هاتفك لا يدعم مستشعر البوصلة',
              style: TextStyle(
                fontFamily: 'Almarai',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D2E1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'اتجاه القبلة يبعد ${state.qiblahBearing.toStringAsFixed(1)} درجة من الشمال الحقيقي.',
              style: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.read<QiblahCubit>().retry(),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'حاول مرة أخرى',
                style: TextStyle(
                  fontFamily: 'Almarai',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationOverlay() => Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.vibration, color: Colors.orange, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'البوصلة غير دقيقة، يرجى تحريك الهاتف بحركة 8 (∞) للمعايرة',
                  style: TextStyle(
                    fontFamily: 'Almarai',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildSuccessState(QiblahState state) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withValues(alpha: 0.6),
              AppColors.primaryColor.withValues(alpha: 0.25),
              AppColors.primaryColor.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: QiblahCompass(
          headingAngle: state.headingAngle,
          qiblahAngle: state.qiblahAngle,
          isAligned: state.isAligned,
          isLoading: state.status == QiblahStatus.loading,
          sensorAccuracy: state.sensorAccuracy,
        ),
      );
}
