import 'dart:async';

import 'package:fazakir/Features/prayer_times/presentation/manager/cubits/prayer_times_cubit/prayer_times_cubit.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;

String _pad(int n) => n.toString().padLeft(2, '0');

/// A single compact line showing the next prayer and a live countdown.
class NextPrayerLine extends StatefulWidget {
  const NextPrayerLine({super.key});

  @override
  State<NextPrayerLine> createState() => _NextPrayerLineState();
}

class _NextPrayerLineState extends State<NextPrayerLine> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  PrayerEnum? _nextPrayer;
  DateTime? _nextTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tick();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) _tick();
      });
    });
  }

  void _tick() {
    final cubit = context.read<PrayerTimesCubit>();
    final pe = cubit.nextPrayerEnum;
    final time = cubit.nextPrayerTime;
    if (pe == null || time == null) return;
    final diff = time.difference(DateTime.now());
    setState(() {
      _nextPrayer = pe;
      _nextTime = time;
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerTimesCubit, PrayerTimesState>(
      listener: (_, __) => _tick(),
      child: _buildLine(context),
    );
  }

  Widget _buildLine(BuildContext context) {
    final prayer = _nextPrayer;
    final time = _nextTime;

    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    final countdown = '${_pad(h)}:${_pad(m)}:${_pad(s)}';
    final timeStr =
        time != null ? intl.DateFormat('h:mm a').format(time) : '--:--';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (prayer != null)
            SvgPicture.asset(
              prayer.iconSVGPath,
              width: 22,
              height: 22,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
          else
            const Icon(Icons.mosque_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prayer != null
                  ? 'صلاة ${prayer.arabicName} • $timeStr'
                  : 'الصلاة القادمة',
              style: AppFontStyles.styleBold14(context)
                  .copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            countdown,
            style: AppFontStyles.styleBold14(context).copyWith(
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
