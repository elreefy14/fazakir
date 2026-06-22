import 'package:fazakir/Features/prayer_tracker/domain/entities/prayer_day_entity.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class PrayerProgressChart extends StatefulWidget {
  final List<PrayerDayEntity> past30Days;

  const PrayerProgressChart({super.key, required this.past30Days});

  @override
  State<PrayerProgressChart> createState() => _PrayerProgressChartState();
}

class _PrayerProgressChartState extends State<PrayerProgressChart> {
  // 0 = last 7 days, 1 = last 30 days
  int _selectedRange = 0;
  int? _touchedIndex;

  List<PrayerDayEntity> get _days {
    final count = _selectedRange == 0 ? 7 : 30;
    final all = widget.past30Days;
    if (all.length <= count) return all;
    return all.sublist(all.length - count);
  }

  Color _barColor(int score) {
    if (score == 5) return AppColors.primaryColor;
    if (score >= 3) return AppColors.primaryColor.withValues(alpha: 0.55);
    if (score >= 1) return AppColors.primaryColor.withValues(alpha: 0.3);
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final completedDays = days.where((d) => d.score == 5).length;
    final totalPossible = days.length * 5;
    final totalDone = days.fold(0, (s, d) => s + d.score);
    final pct = totalPossible == 0 ? 0 : (totalDone / totalPossible * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RangeToggle(
                  selected: _selectedRange,
                  onChanged: (v) => setState(() {
                    _selectedRange = v;
                    _touchedIndex = null;
                  }),
                ),
                Text(
                  'تقدم الصلوات',
                  style: AppFontStyles.styleBold16(context).copyWith(
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Summary row
            Text(
              '$completedDays يوم مكتمل · $pct% التزام',
              style: AppFontStyles.styleMedium14(context).copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Chart
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: 5,
                  minY: 0,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.spot != null &&
                            event is! FlTapUpEvent &&
                            event is! FlPanEndEvent) {
                          _touchedIndex =
                              response!.spot!.touchedBarGroupIndex;
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primaryColor,
                      tooltipRoundedRadius: 10,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = days[groupIndex];
                        final label =
                            intl.DateFormat('EEE', 'ar').format(day.date);
                        return BarTooltipItem(
                          '$label\n${day.score}/5',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            fontFamily: 'Almarai',
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                              fontFamily: 'Almarai',
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= days.length) {
                            return const SizedBox();
                          }
                          // Show fewer labels when 30-day view to avoid crowding
                          if (_selectedRange == 1 && idx % 5 != 0) {
                            return const SizedBox();
                          }
                          final label = _selectedRange == 0
                              ? intl.DateFormat('EEE', 'ar')
                                  .format(days[idx].date)
                              : '${days[idx].date.day}';
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: _selectedRange == 0 ? 12 : 10,
                                fontFamily: 'Almarai',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade100,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(days.length, (i) {
                    final score = days[i].score;
                    final isTouched = _touchedIndex == i;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: score == 0 ? 0.15 : score.toDouble(),
                          color: isTouched
                              ? AppColors.primaryColor
                              : _barColor(score),
                          width: _selectedRange == 0 ? 22 : 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 5,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                    color: AppColors.primaryColor, label: '5 صلوات'),
                const SizedBox(width: 16),
                _LegendDot(
                    color: AppColors.primaryColor.withValues(alpha: 0.55),
                    label: '3-4'),
                const SizedBox(width: 16),
                _LegendDot(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    label: '1-2'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.grey.shade300, label: 'لا شيء'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _RangeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(label: '7 أيام', active: selected == 0, onTap: () => onChanged(0)),
          _Tab(label: '30 يوم', active: selected == 1, onTap: () => onChanged(1)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppFontStyles.styleMedium14(context).copyWith(
            color: active ? Colors.white : Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppFontStyles.styleRegular11(context).copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
