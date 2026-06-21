import 'package:objectbox/objectbox.dart';

@Entity()
class PrayerDayEntity {
  @Id()
  int id;

  @Property(type: PropertyType.date)
  DateTime date;

  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  PrayerDayEntity({
    this.id = 0,
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
  });

  int get score {
    int count = 0;
    if (fajr) count++;
    if (dhuhr) count++;
    if (asr) count++;
    if (maghrib) count++;
    if (isha) count++;
    return count;
  }
}
