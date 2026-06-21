import 'package:fazakir/Features/prayer_tracker/domain/entities/prayer_day_entity.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_state.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/object_box_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrayerTrackerCubit extends Cubit<PrayerTrackerState> {
  PrayerTrackerCubit() : super(PrayerTrackerInitial());

  DateTime _selectedDate = DateTime.now();

  void initTracker() {
    emit(PrayerTrackerLoading());
    _loadDataForDate(_selectedDate);
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    emit(PrayerTrackerLoading());
    _loadDataForDate(_selectedDate);
  }

  void _loadDataForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    PrayerDayEntity? dayEntity =
        ObjectBoxManager.instance.getPrayerDay(normalizedDate);

    if (dayEntity == null) {
      dayEntity = PrayerDayEntity(date: normalizedDate);
      ObjectBoxManager.instance.savePrayerDay(dayEntity);
    }

    _emitLoadedState(dayEntity, normalizedDate);
  }

  void togglePrayer(PrayerEnum prayer, bool isDone) {
    if (state is! PrayerTrackerLoaded) return;

    final currentState = state as PrayerTrackerLoaded;
    final currentDay = currentState.currentDay;

    switch (prayer) {
      case PrayerEnum.fajr:
        currentDay.fajr = isDone;
        break;
      case PrayerEnum.dhuhr:
        currentDay.dhuhr = isDone;
        break;
      case PrayerEnum.asr:
        currentDay.asr = isDone;
        break;
      case PrayerEnum.maghrib:
        currentDay.maghrib = isDone;
        break;
      case PrayerEnum.isha:
        currentDay.isha = isDone;
        break;
      default:
        break;
    }

    ObjectBoxManager.instance.savePrayerDay(currentDay);
    _emitLoadedState(currentDay, _selectedDate);
  }

  void resetDay() {
    if (state is! PrayerTrackerLoaded) return;

    final currentState = state as PrayerTrackerLoaded;
    final currentDay = currentState.currentDay;

    currentDay.fajr = false;
    currentDay.dhuhr = false;
    currentDay.asr = false;
    currentDay.maghrib = false;
    currentDay.isha = false;

    ObjectBoxManager.instance.savePrayerDay(currentDay);
    _emitLoadedState(currentDay, _selectedDate);
  }

  void _emitLoadedState(PrayerDayEntity currentDay, DateTime selectedDate) {
    final allDays = ObjectBoxManager.instance.getAllPrayerDays();

    allDays.sort((a, b) => b.date.compareTo(a.date));

    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final daysMap = {
      for (var day in allDays)
        DateTime(day.date.year, day.date.month, day.date.day): day
    };

    // Current streak
    int streak = 0;
    DateTime checkDate = today;
    bool foundMissing = false;
    while (!foundMissing) {
      final day = daysMap[checkDate];
      if (day != null && day.score == 5) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (checkDate == today && day != null && day.score < 5) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          final yesterday = daysMap[checkDate];
          if (yesterday != null && yesterday.score == 5) {
            continue;
          }
        }
        foundMissing = true;
      }
    }

    // Longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    final sortedDays = allDays.reversed.toList();
    for (int i = 0; i < sortedDays.length; i++) {
      if (sortedDays[i].score == 5) {
        tempStreak++;
        if (i > 0) {
          final prevDate = DateTime(sortedDays[i - 1].date.year,
              sortedDays[i - 1].date.month, sortedDays[i - 1].date.day);
          final currDate = DateTime(sortedDays[i].date.year,
              sortedDays[i].date.month, sortedDays[i].date.day);
          if (currDate.difference(prevDate).inDays != 1) {
            tempStreak = 1;
          }
        }
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 0;
      }
    }

    // Last completed day
    DateTime? lastCompletedDay;
    for (var day in allDays) {
      if (day.score == 5) {
        lastCompletedDay =
            DateTime(day.date.year, day.date.month, day.date.day);
        break;
      }
    }

    // Total days with all 5 prayers
    int totalDays = allDays.where((d) => d.score == 5).length;

    // Total prayers ever
    int totalPrayers = allDays.fold(0, (sum, d) => sum + d.score);

    // Past 30 days for average
    final past30Days = <PrayerDayEntity>[];
    int totalScore = 0;
    for (int i = 0; i < 30; i++) {
      final d = today.subtract(Duration(days: i));
      final dayEntity = daysMap[d] ?? PrayerDayEntity(date: d);
      past30Days.add(dayEntity);
      totalScore += dayEntity.score;
    }
    double dailyAverage = totalScore / (30 * 5);

    emit(PrayerTrackerLoaded(
      currentDay: currentDay,
      selectedDate: selectedDate,
      currentStreak: streak,
      longestStreak: longestStreak,
      dailyAverage: dailyAverage,
      past30Days: past30Days.reversed.toList(),
      lastCompletedDay: lastCompletedDay,
      totalDays: totalDays,
      totalPrayers: totalPrayers,
    ));
  }
}
