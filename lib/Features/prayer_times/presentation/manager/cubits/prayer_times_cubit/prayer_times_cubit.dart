import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:fazakir/Features/prayer_times/data/services/aladhan_prayer_service.dart';
import 'package:fazakir/Features/prayer_times/domain/entities/prayer_entity.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/extensions/cubit_safe_emit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

part 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit() : super(PrayerTimesInitial());

  // adhan object – kept for getParameters / coordinates reference only
  static PrayerTimes prayerTimes = PrayerTimes(
    Coordinates(30.04444, 31.23583),
    DateComponents.from(DateTime.now()),
    CalculationMethod.egyptian.getParameters(),
  );

  PrayerTimes get getPrayerTimes => prayerTimes;

  // ── Prayer times as display strings ──────────────────────────────────────
  List<PrayerEntity> prayerList = _buildPrayerListFromAdhan(prayerTimes);

  // ── Prayer times as raw DateTime (API-accurate) ───────────────────────────
  // Key = PrayerEnum, Value = DateTime for today
  Map<PrayerEnum, DateTime> prayerDateTimes = {};

  // ── Next prayer info (always derived from prayerDateTimes) ────────────────
  PrayerEnum? nextPrayerEnum;
  DateTime? nextPrayerTime;

  // Legacy accessor used by RemainTimeForNextPrayerText
  String get nextPrayerName => nextPrayerEnum?.englishName ?? 'none';

  Timer? _timer;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static List<PrayerEntity> _buildPrayerListFromAdhan(PrayerTimes pt) {
    return [
      PrayerEntity(prayer: PrayerEnum.fajr,    time: DateFormat.jm().format(pt.fajr)),
      PrayerEntity(prayer: PrayerEnum.sunrise,  time: DateFormat.jm().format(pt.sunrise)),
      PrayerEntity(prayer: PrayerEnum.dhuhr,    time: DateFormat.jm().format(pt.dhuhr)),
      PrayerEntity(prayer: PrayerEnum.asr,      time: DateFormat.jm().format(pt.asr)),
      PrayerEntity(prayer: PrayerEnum.maghrib,  time: DateFormat.jm().format(pt.maghrib)),
      PrayerEntity(prayer: PrayerEnum.isha,     time: DateFormat.jm().format(pt.isha)),
    ];
  }

  List<PrayerEntity> _buildPrayerListFromApi(AladhanPrayerTimings t) {
    return [
      PrayerEntity(prayer: PrayerEnum.fajr,    time: AladhanPrayerService.to12Hour(t.fajr)),
      PrayerEntity(prayer: PrayerEnum.sunrise,  time: AladhanPrayerService.to12Hour(t.sunrise)),
      PrayerEntity(prayer: PrayerEnum.dhuhr,    time: AladhanPrayerService.to12Hour(t.dhuhr)),
      PrayerEntity(prayer: PrayerEnum.asr,      time: AladhanPrayerService.to12Hour(t.asr)),
      PrayerEntity(prayer: PrayerEnum.maghrib,  time: AladhanPrayerService.to12Hour(t.maghrib)),
      PrayerEntity(prayer: PrayerEnum.isha,     time: AladhanPrayerService.to12Hour(t.isha)),
    ];
  }

  /// Build raw DateTime map from API timings (source of truth for countdown)
  Map<PrayerEnum, DateTime> _buildDateTimesFromApi(AladhanPrayerTimings t) {
    final m = <PrayerEnum, DateTime>{};
    void add(PrayerEnum e, String hhmm) {
      final dt = AladhanPrayerService.toDateTime(hhmm);
      if (dt != null) m[e] = dt;
    }
    add(PrayerEnum.fajr,    t.fajr);
    add(PrayerEnum.sunrise, t.sunrise);
    add(PrayerEnum.dhuhr,   t.dhuhr);
    add(PrayerEnum.asr,     t.asr);
    add(PrayerEnum.maghrib, t.maghrib);
    add(PrayerEnum.isha,    t.isha);
    return m;
  }

  /// Build raw DateTime map from adhan (fallback)
  Map<PrayerEnum, DateTime> _buildDateTimesFromAdhan(PrayerTimes pt) {
    return {
      PrayerEnum.fajr:    pt.fajr,
      PrayerEnum.sunrise: pt.sunrise,
      PrayerEnum.dhuhr:   pt.dhuhr,
      PrayerEnum.asr:     pt.asr,
      PrayerEnum.maghrib: pt.maghrib,
      PrayerEnum.isha:    pt.isha,
    };
  }

  /// Compute next prayer from the raw DateTime map
  void _refreshNextPrayer() {
    if (prayerDateTimes.isEmpty) return;

    final now = DateTime.now();
    final order = [
      PrayerEnum.fajr,
      PrayerEnum.dhuhr,
      PrayerEnum.asr,
      PrayerEnum.maghrib,
      PrayerEnum.isha,
    ];

    for (final p in order) {
      final dt = prayerDateTimes[p];
      if (dt != null && dt.isAfter(now)) {
        nextPrayerEnum = p;
        nextPrayerTime = dt;
        return;
      }
    }

    // All prayers passed – next is Fajr tomorrow
    final fajr = prayerDateTimes[PrayerEnum.fajr];
    if (fajr != null) {
      nextPrayerEnum = PrayerEnum.fajr;
      nextPrayerTime = fajr.add(const Duration(days: 1));
    }
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshNextPrayer();
      safeEmit(PrayerTimesInitial());
    });
  }

  void stopTimer() => _timer?.cancel();

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  // ── Edit (legacy – called when location changes or adhan fallback) ─────────

  void editPrayerTimes(PrayerTimes newPrayerTimes) {
    if (newPrayerTimes.coordinates.latitude ==
            prayerTimes.coordinates.latitude &&
        newPrayerTimes.coordinates.longitude ==
            prayerTimes.coordinates.longitude &&
        newPrayerTimes.dateComponents == prayerTimes.dateComponents) {
      return;
    }
    safeEmit(PrayerTimesLoading());
    prayerTimes = newPrayerTimes;
    prayerList = _buildPrayerListFromAdhan(prayerTimes);
    prayerDateTimes = _buildDateTimesFromAdhan(prayerTimes);
    _refreshNextPrayer();
    safeEmit(PrayerTimesLoaded());
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<Position?> getLocationData() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initPrayerTime() async {
    safeEmit(PrayerTimesLoading());

    // Set adhan defaults immediately so UI isn't empty
    prayerDateTimes = _buildDateTimesFromAdhan(prayerTimes);
    _refreshNextPrayer();
    safeEmit(PrayerTimesLoaded());

    final position = await getLocationData();

    if (position != null) {
      // Try Aladhan API (accurate)
      final apiTimings = await AladhanPrayerService.fetchTimings(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (apiTimings != null) {
        prayerList     = _buildPrayerListFromApi(apiTimings);
        prayerDateTimes = _buildDateTimesFromApi(apiTimings);
        _refreshNextPrayer();
        safeEmit(PrayerTimesLoaded());
        startTimer();
        return;
      }

      // Fallback to adhan with correct location
      prayerTimes = PrayerTimes(
        Coordinates(position.latitude, position.longitude),
        DateComponents.from(DateTime.now()),
        CalculationMethod.egyptian.getParameters(),
      );
      prayerList     = _buildPrayerListFromAdhan(prayerTimes);
      prayerDateTimes = _buildDateTimesFromAdhan(prayerTimes);
      _refreshNextPrayer();
      safeEmit(PrayerTimesLoaded());
    } else {
      safeEmit(PrayerTimesLoaded());
    }

    startTimer();
  }
}
