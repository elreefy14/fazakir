import 'dart:convert';
import 'package:http/http.dart' as http;

class AladhanPrayerTimings {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String timezone;

  const AladhanPrayerTimings({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.timezone,
  });
}

class AladhanPrayerService {
  static const _baseUrl = 'https://api.aladhan.com/v1/timings';

  // Method 5 = Egyptian General Authority of Survey
  static const _method = 5;

  static Future<AladhanPrayerTimings?> fetchTimings({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.year}';

      final uri = Uri.parse('$_baseUrl/$date').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': _method.toString(),
      });

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['code'] == 200) {
          final timings =
              json['data']['timings'] as Map<String, dynamic>;
          final meta = json['data']['meta'] as Map<String, dynamic>;
          final tz = meta['timezone'] as String? ?? 'UTC';

          return AladhanPrayerTimings(
            fajr: _clean(timings['Fajr']),
            sunrise: _clean(timings['Sunrise']),
            dhuhr: _clean(timings['Dhuhr']),
            asr: _clean(timings['Asr']),
            maghrib: _clean(timings['Maghrib']),
            isha: _clean(timings['Isha']),
            timezone: tz,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // API sometimes returns "04:28 (EET)" — strip the timezone suffix
  static String _clean(dynamic raw) {
    final s = raw?.toString() ?? '';
    return s.contains(' ') ? s.split(' ').first : s;
  }

  // Convert "HH:mm" to a DateTime for today
  static DateTime? toDateTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  // Format "HH:mm" → "h:mm AM/PM"
  static String to12Hour(String hhmm) {
    final dt = toDateTime(hhmm);
    if (dt == null) return hhmm;
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:$min $period';
  }
}
