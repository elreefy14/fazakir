import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:fazakir/core/utils/extensions/cubit_safe_emit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

part 'qiblah_state.dart';

class QiblahCubit extends Cubit<QiblahState> {
  QiblahCubit() : super(const QiblahState());

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<ServiceStatus>? _locationSubscription;
  bool _isInitialized = false;
  Position? _currentPosition;
  Timer? _stillnessTimer;
  Timer? _initTimeoutTimer;
  double? _lastHeading;
  double? _lastSmoothedHeading;
  int _stillnessCount = 0;
  bool _hasTriggeredFeedback = false;

  static const double _smoothingFactor = 0.2;
  static const double _alignmentThreshold = 0.09;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    safeEmit(state.copyWith(status: QiblahStatus.loading));
    _setupLocationServiceListener();
    await _startIfGranted();
  }

  void _setupLocationServiceListener() {
    _locationSubscription = Geolocator.getServiceStatusStream().listen(
      (status) async {
        if (status == ServiceStatus.enabled) {
          await _startIfGranted();
        } else {
          await _compassSubscription?.cancel();
          safeEmit(state.copyWith(
            status: QiblahStatus.error,
            message: 'من فضلك شغل خدمة الموقع لاستخدام البوصلة',
          ));
        }
      },
    );
  }

  Future<void> _startIfGranted() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        safeEmit(state.copyWith(
          status: QiblahStatus.error,
          message: 'من فضلك شغل خدمة الموقع لاستخدام البوصلة',
        ));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        safeEmit(state.copyWith(
          status: QiblahStatus.error,
          message: 'يرجى منح الصلاحية للوصول إلى الموقع لاستخدام البوصلة',
        ));
        return;
      }

      await _startCompass();
    } catch (e) {
      safeEmit(state.copyWith(
        status: QiblahStatus.error,
        message: 'خطأ في التحقق من حالة الموقع: $e',
      ));
    }
  }

  Future<void> _startCompass() async {
    if (FlutterCompass.events == null) {
      safeEmit(state.copyWith(
        status: QiblahStatus.success,
        hasMagnetometer: false,
      ));
      return;
    }

    await _compassSubscription?.cancel();
    _hasTriggeredFeedback = false;

    _compassSubscription = FlutterCompass.events!.listen(
      _handleCompassData,
      onError: (error) => safeEmit(state.copyWith(
        status: QiblahStatus.error,
        message: 'خطأ في البوصلة: $error',
      )),
    );

    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (state.status == QiblahStatus.loading ||
          (state.status == QiblahStatus.success && _lastHeading == null)) {
        if (!isClosed) {
          safeEmit(state.copyWith(
            status: QiblahStatus.success,
            hasMagnetometer: false,
          ));
        }
      }
    });
  }

  Future<void> _handleCompassData(CompassEvent data) async {
    _initTimeoutTimer?.cancel();

    if (_currentPosition == null) {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
      } catch (_) {}
    }

    double qiblahBearing = 0.0;
    if (_currentPosition != null) {
      qiblahBearing = Qibla(Coordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      )).direction;
    }

    final heading = _smoothHeading(data.heading);
    final accuracy = data.accuracy;

    if (heading != null) {
      if (_lastHeading != null && (heading - _lastHeading!).abs() < 0.001) {
        _stillnessCount++;
      } else {
        _stillnessCount = 0;
      }
      _lastHeading = heading;
    }

    _stillnessTimer?.cancel();
    _stillnessTimer = Timer(const Duration(seconds: 3), () {
      if (state.status == QiblahStatus.success && state.hasMagnetometer) {
        if (!isClosed) safeEmit(state.copyWith(hasMagnetometer: false));
      }
    });

    bool hasMagnetometer = state.hasMagnetometer;
    bool calibrationNeeded = false;

    if (heading == null || _stillnessCount > 50) {
      hasMagnetometer = false;
    } else {
      hasMagnetometer = true;
      if (accuracy != null) {
        if (Platform.isAndroid && accuracy < 2) {
          calibrationNeeded = true;
        } else if (Platform.isIOS && (accuracy < 0 || accuracy > 20)) {
          calibrationNeeded = true;
        }
      }
    }

    final currentHeading = heading ?? 0.0;
    final headingRad = -currentHeading * pi / 180;
    final qiblahRad = (qiblahBearing - currentHeading) * pi / 180;
    final isAligned = (qiblahRad % (2 * pi)).abs() < _alignmentThreshold;

    _triggerHapticFeedback(isAligned);

    safeEmit(state.copyWith(
      status: QiblahStatus.success,
      qiblahAngle: qiblahRad,
      headingAngle: headingRad,
      isAligned: isAligned,
      sensorAccuracy: accuracy,
      isCalibrationNeeded: calibrationNeeded,
      qiblahBearing: qiblahBearing,
      hasMagnetometer: hasMagnetometer,
    ));
  }

  double? _smoothHeading(double? newHeading) {
    if (newHeading == null) return null;
    if (_lastSmoothedHeading == null) {
      _lastSmoothedHeading = newHeading;
      return newHeading;
    }
    double diff = newHeading - _lastSmoothedHeading!;
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }
    _lastSmoothedHeading =
        (_lastSmoothedHeading! + (_smoothingFactor * diff) + 360) % 360;
    return _lastSmoothedHeading;
  }

  void _triggerHapticFeedback(bool isAligned) {
    if (isAligned && !_hasTriggeredFeedback) {
      HapticFeedback.heavyImpact();
      _hasTriggeredFeedback = true;
    } else if (!isAligned) {
      _hasTriggeredFeedback = false;
    }
  }

  Future<void> retry() async {
    await _compassSubscription?.cancel();
    await _locationSubscription?.cancel();
    _compassSubscription = null;
    _locationSubscription = null;
    _isInitialized = false;
    _currentPosition = null;
    _lastHeading = null;
    _lastSmoothedHeading = null;
    _stillnessCount = 0;
    safeEmit(const QiblahState());
    await init();
  }

  @override
  Future<void> close() async {
    _stillnessTimer?.cancel();
    _initTimeoutTimer?.cancel();
    await _compassSubscription?.cancel();
    await _locationSubscription?.cancel();
    return super.close();
  }
}
