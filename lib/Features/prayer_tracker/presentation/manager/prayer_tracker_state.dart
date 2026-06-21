
import 'package:fazakir/Features/prayer_tracker/domain/entities/prayer_day_entity.dart';

abstract class PrayerTrackerState {
  const PrayerTrackerState();
}

class PrayerTrackerInitial extends PrayerTrackerState {}

class PrayerTrackerLoading extends PrayerTrackerState {}

class PrayerTrackerLoaded extends PrayerTrackerState {
  final PrayerDayEntity currentDay;
  final DateTime selectedDate;
  final int currentStreak;
  final int longestStreak;
  final double dailyAverage;
  final List<PrayerDayEntity> past30Days;
  final DateTime? lastCompletedDay;
  final int totalDays;
  final int totalPrayers;

  const PrayerTrackerLoaded({
    required this.currentDay,
    required this.selectedDate,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyAverage,
    required this.past30Days,
    this.lastCompletedDay,
    required this.totalDays,
    required this.totalPrayers,
  });
}
