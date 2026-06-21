import 'package:fazakir/Features/prayer_times/presentation/manager/cubits/prayer_times_cubit/prayer_times_cubit.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_cubit.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_state.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePrayerTrackerList extends StatelessWidget {
  const HomePrayerTrackerList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerTrackerCubit, PrayerTrackerState>(
      builder: (context, state) {
        if (state is PrayerTrackerLoaded) {
          final currentDay = state.currentDay;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPrayerRow(
                context,
                prayerName: PrayerEnum.fajr.arabicName,
                prayerTime: _getPrayerTime(context, PrayerEnum.fajr),
                isDone: currentDay.fajr,
                onChanged: (val) {
                  context
                      .read<PrayerTrackerCubit>()
                      .togglePrayer(PrayerEnum.fajr, val);
                },
              ),
              const SizedBox(height: 8),
              _buildPrayerRow(
                context,
                prayerName: PrayerEnum.dhuhr.arabicName,
                prayerTime: _getPrayerTime(context, PrayerEnum.dhuhr),
                isDone: currentDay.dhuhr,
                onChanged: (val) {
                  context
                      .read<PrayerTrackerCubit>()
                      .togglePrayer(PrayerEnum.dhuhr, val);
                },
              ),
              const SizedBox(height: 8),
              _buildPrayerRow(
                context,
                prayerName: PrayerEnum.asr.arabicName,
                prayerTime: _getPrayerTime(context, PrayerEnum.asr),
                isDone: currentDay.asr,
                onChanged: (val) {
                  context
                      .read<PrayerTrackerCubit>()
                      .togglePrayer(PrayerEnum.asr, val);
                },
              ),
              const SizedBox(height: 8),
              _buildPrayerRow(
                context,
                prayerName: PrayerEnum.maghrib.arabicName,
                prayerTime: _getPrayerTime(context, PrayerEnum.maghrib),
                isDone: currentDay.maghrib,
                onChanged: (val) {
                  context
                      .read<PrayerTrackerCubit>()
                      .togglePrayer(PrayerEnum.maghrib, val);
                },
              ),
              const SizedBox(height: 8),
              _buildPrayerRow(
                context,
                prayerName: PrayerEnum.isha.arabicName,
                prayerTime: _getPrayerTime(context, PrayerEnum.isha),
                isDone: currentDay.isha,
                onChanged: (val) {
                  context
                      .read<PrayerTrackerCubit>()
                      .togglePrayer(PrayerEnum.isha, val);
                },
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  String _getPrayerTime(BuildContext context, PrayerEnum prayer) {
    try {
      final prayerTimes = context.watch<PrayerTimesCubit>().prayerList;
      final entity = prayerTimes.firstWhere((e) => e.prayer == prayer);
      return entity.time;
    } catch (_) {
      return '';
    }
  }

  Widget _buildPrayerRow(
    BuildContext context, {
    required String prayerName,
    required String prayerTime,
    required bool isDone,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!isDone),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDone
              ? AppColors.primaryColor.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppColors.primaryColor.withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDone
                  ? AppColors.primaryColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      isDone ? AppColors.primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (prayerTime.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                prayerTime,
                style: AppFontStyles.styleRegular13(context).copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
            const Spacer(),
            Text(
              prayerName,
              style: AppFontStyles.styleBold16(context).copyWith(
                color: isDone
                    ? AppColors.primaryColor
                    : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
