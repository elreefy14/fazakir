import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_cubit.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_state.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

class PrayerStatsView extends StatelessWidget {
  const PrayerStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EA),
      body: BlocBuilder<PrayerTrackerCubit, PrayerTrackerState>(
        builder: (context, state) {
          if (state is PrayerTrackerLoaded) {
            return Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      children: [
                        _buildStreakCard(context, state),
                        const SizedBox(height: 12),
                        _buildLastDayRow(context, state),
                        const SizedBox(height: 12),
                        _buildStatsGrid(context, state),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _buildAppBar(context),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B7355),
            AppColors.primaryColor,
            Color(0xFF5C4A35),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              Text(
                'إحصائيات صلاتك',
                style: AppFontStyles.styleBold20(context).copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, PrayerTrackerLoaded state) {
    final streak = state.currentStreak;
    final hasStreak = streak > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF9E835F),
            AppColors.primaryColor,
            Color(0xFF5C4A35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -10,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Text(
                  'سلسلة الالتزام بالصلاة',
                  style: AppFontStyles.styleBold20(context).copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$streak',
                      style: AppFontStyles.styleRegular70(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'يوم متتالي',
                  style: AppFontStyles.styleMedium16(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 24),
                if (!hasStreak)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'ابدأ رحلتك مع الالتزام بالصلاة اليوم',
                      style: AppFontStyles.styleMedium14(context).copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'أنت في طريقك! واصل',
                          style: AppFontStyles.styleMedium14(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastDayRow(BuildContext context, PrayerTrackerLoaded state) {
    final lastDay = state.lastCompletedDay;
    String lastDayText = 'لم تكمل يوم بعد';
    if (lastDay != null) {
      final today = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day);
      if (lastDay == today) {
        lastDayText = 'اليوم';
      } else if (lastDay ==
          today.subtract(const Duration(days: 1))) {
        lastDayText = 'أمس';
      } else {
        lastDayText = intl.DateFormat('d MMM', 'ar').format(lastDay);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'آخر يوم مكتمل',
                    style: AppFontStyles.styleMedium14(context).copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastDayText == 'لم تكمل يوم بعد'
                        ? lastDayText
                        : lastDayText,
                    style: AppFontStyles.styleBold16(context).copyWith(
                      color: lastDay != null
                          ? AppColors.primaryColor
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1.5,
              height: 40,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    'آخر يوم مكتمل',
                    style: AppFontStyles.styleMedium14(context).copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastDay != null ? lastDayText : 'لم تكمل يوم بعد',
                    style: AppFontStyles.styleBold16(context).copyWith(
                      color: lastDay != null
                          ? AppColors.primaryColor
                          : const Color(0xFFE8A020),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, PrayerTrackerLoaded state) {
    final commitmentRate =
        (state.dailyAverage * 100).toStringAsFixed(0);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context,
          title: 'إجمالي الأيام',
          value: '${state.totalDays} يوم',
          valueColor: AppColors.primaryColor,
          icon: Icons.calendar_today_outlined,
        ),
        _buildStatCard(
          context,
          title: 'أطول سلسلة',
          value: '${state.longestStreak} يوم',
          valueColor: const Color(0xFFE8A020),
          icon: Icons.emoji_events_outlined,
        ),
        _buildStatCard(
          context,
          title: 'نسبة الالتزام',
          value: '$commitmentRate%',
          valueColor: AppColors.primaryColor,
          icon: Icons.pie_chart_outline,
        ),
        _buildStatCard(
          context,
          title: 'إجمالي الصلوات',
          value: '${state.totalPrayers} صلاة',
          valueColor: AppColors.primaryColor,
          icon: Icons.mosque_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      color: AppColors.primaryColor, size: 18),
                ),
                Text(
                  title,
                  style: AppFontStyles.styleMedium14(context).copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: AppFontStyles.styleBold20(context).copyWith(
                color: valueColor,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
