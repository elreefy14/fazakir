import 'dart:async';

import 'package:fazakir/Features/prayer_times/presentation/manager/cubits/prayer_times_cubit/prayer_times_cubit.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;

String _pad(int n) => n.toString().padLeft(2, '0');

class NextPrayerCard extends StatefulWidget {
  const NextPrayerCard({super.key});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  Timer? _timer;

  // These are read fresh on every tick directly from the cubit
  Duration _remaining = Duration.zero;
  PrayerEnum? _nextPrayer;
  DateTime? _nextTime;

  @override
  void initState() {
    super.initState();
    // Defer first tick so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tick();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) _tick();
      });
    });
  }

  void _tick() {
    final cubit = context.read<PrayerTimesCubit>();

    // Use the cubit's pre-computed DateTime values directly – no string parsing
    final pe   = cubit.nextPrayerEnum;
    final time = cubit.nextPrayerTime;

    if (pe == null || time == null) return;

    final diff = time.difference(DateTime.now());

    setState(() {
      _nextPrayer = pe;
      _nextTime   = time;
      _remaining  = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-tick whenever the cubit emits (e.g. after API loads)
    return BlocListener<PrayerTimesCubit, PrayerTimesState>(
      listener: (_, __) => _tick(),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final prayer = _nextPrayer;
    final time   = _nextTime;

    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    // Progress bar: fraction elapsed in a 3-hour window before next prayer
    double progress = 0;
    if (time != null) {
      const window = Duration(hours: 3);
      final elapsed = window - _remaining;
      progress = (elapsed.inSeconds / window.inSeconds).clamp(0.0, 1.0);
    }

    final timeStr = time != null
        ? intl.DateFormat('h:mm a').format(time)
        : '--:--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF9E835F),
            AppColors.primaryColor,
            Color(0xFF4A3828),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: -24, right: -24, child: _circle(100, 0.06)),
          Positioned(bottom: -20, left: -20, child: _circle(80, 0.06)),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row: time badge | prayer name + icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        timeStr,
                        style: AppFontStyles.styleBold14(context)
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    // Prayer name + icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          prayer != null
                              ? 'صلاة ${prayer.arabicName}'
                              : 'الصلاة القادمة',
                          style: AppFontStyles.styleBold20(context)
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        if (prayer != null)
                          SvgPicture.asset(
                            prayer.iconSVGPath,
                            width: 26,
                            height: 26,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Countdown digits
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _unit(context, _pad(h), 'ساعة'),
                    _sep(context),
                    _unit(context, _pad(m), 'دقيقة'),
                    _sep(context),
                    _unit(context, _pad(s), 'ثانية'),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الوقت المتبقي',
                      style: AppFontStyles.styleMedium14(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  Widget _unit(BuildContext context, String value, String label) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppFontStyles.styleBold24(context).copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppFontStyles.styleRegular11(context)
              .copyWith(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _sep(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          ':',
          style: AppFontStyles.styleBold24(context)
              .copyWith(color: Colors.white.withValues(alpha: 0.6)),
        ),
      );
}
