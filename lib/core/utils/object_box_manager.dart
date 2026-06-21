import 'package:fazakir/Features/ahadith/domain/entities/hadith_entity.dart';
import 'package:fazakir/Features/prayer_tracker/domain/entities/prayer_day_entity.dart';
import 'package:fazakir/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ObjectBoxManager {
  static late final ObjectBoxManager _instance;
  late final Store _store;
  late final Box<HadithEntity> _hadithBox;
  late final Box<PrayerDayEntity> _prayerDayBox;

  ObjectBoxManager._create(this._store) {
    _hadithBox = Box<HadithEntity>(_store);
    _prayerDayBox = Box<PrayerDayEntity>(_store);
  }

  static Future<void> initialize() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsDir.path, "hadith-db"));
    _instance = ObjectBoxManager._create(store);
  }

  static ObjectBoxManager get instance => _instance;

  Future<List<int>> putManyAsync(List<HadithEntity> hadiths) async {
    return await _hadithBox.putManyAsync(hadiths);
  }

  Future<List<HadithEntity>> getAllAsync() async {
    return await _hadithBox.getAllAsync();
  }

  PrayerDayEntity? getPrayerDay(DateTime date) {
    final query = _prayerDayBox.query(PrayerDayEntity_.date.equals(date.millisecondsSinceEpoch)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  int savePrayerDay(PrayerDayEntity entity) {
    return _prayerDayBox.put(entity);
  }

  List<PrayerDayEntity> getAllPrayerDays() {
    return _prayerDayBox.getAll();
  }

  void close() {
    _store.close();
  }
}
