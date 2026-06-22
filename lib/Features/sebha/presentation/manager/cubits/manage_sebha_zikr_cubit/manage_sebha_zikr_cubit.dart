import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/Features/sebha/data/repos/sebha_zikr_repo.dart';
import 'package:fazakir/core/utils/extensions/cubit_safe_emit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manage_sebha_zikr_state.dart';

class ManageSebhaZikrCubit extends Cubit<ManageSebhaZikrState> {
  ManageSebhaZikrCubit() : super(ManageSebhaZikrInitial());
  final GlobalKey<FormState> formKeyAdd = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyEdit = GlobalKey<FormState>();
  final TextEditingController textAddZikr = TextEditingController();
  final TextEditingController textAddZikrCount = TextEditingController();
  String? editZikr;
  int? editZikrCount;

  void getSebhaZikr() {
    safeEmit(ManageSebhaZikrLoading());
    final List<SebhaZikrModel> data = SebhaZikrRepo.getZikrs();
    safeEmit(GetAzkarSuccess(azkar: data));
  }

  Future<void> addSebhaZikr(SebhaZikrModel zikrModel) async {
    safeEmit(ManageSebhaZikrLoading());
    await SebhaZikrRepo.addZikr(zikrModel);
    getSebhaZikr();
  }

  Future<void> addDefaultSebhaZikr() async {
    const List<String> defaultZikrTitles = [
      'سُبْحَانَ اللَّهِ',
      'الْحَمْدُ لِلَّهِ',
      'لَا إِلَهَ إِلَّا اللهُ',
      'اللهُ أَكْبَرُ',
      'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'سُبْحَانَ اللَّهِ الْعَظِيمِ',
      'اللَّهُـمَّ اغْفِرْ لِي وَارْحَمْنِي',
      'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ العَفْوَ فَاعْفُ عَنِّي',
      'لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَاللَّهُ أَكْبَرُ',
      'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ',
      'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ العَرْشِ العَظِيمِ',
      'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ المُلكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'اللَّهُمَّ يَا مُقَلِّبَ القُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
      'اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ فِي الأَوَّلِينَ وَالآخِرِينَ',
      'الحمد لله عدد ما خلق',
      'الحمد لله ملء ما خلق',
      'الحمد لله عدد ما في السماوات وما في الأرض',
      'الحمد لله عدد ما أحصى كتابه',
      'الحمد لله عدد كل شيء',
      'الحمد لله ملء كل شيء',
      'سبحان الله عدد ما خلق',
      'سبحان الله ملء ما خلق',
      'سبحان الله عدد ما في السماوات وما في الأرض',
      'سبحان الله عدد كل شيء',
      'سبحان الله ملء كل شيء',
      'الله أكبر عدد ما خلق',
      'الله أكبر ملء ما خلق',
      'الله أكبر عدد ما في السماوات وما في الأرض',
      'الله أكبر ملء كل شيء',
      'لَا إِلَهَ إِلَّا اللَّهُ عَدَدَ مَا خَلَقَ',
      'لَا إِلَهَ إِلَّا اللَّهُ مِلْءَ مَا خَلَقَ',
      'لَا إِلَهَ إِلَّا اللَّهُ عَدَدَ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ',
      'لَا إِلَهَ إِلَّا اللَّهُ زِنَةَ عَرْشِهِ',
      'لَا إِلَهَ إِلَّا اللَّهُ مِدَادَ كَلِمَاتِهِ',
      'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ',
      'رَبِّ اغْفِرْ لِي',
      'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      'اللَّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالجَنَّةَ، وَأَعُوذُ بِكَ مِنْ سَخَطِكَ وَالنَّارِ',
      'اللَّهُمَّ اجعلني لك ذَكَّاراً، لك شَكَّاراً، لك رَهَّاباً، لك مِطواعاً، إليك أَوَّاهًا مُنيباً',
      'رَبِّ زِدْنِي عِلْمًا',
      'اللَّهُمَّ طَهِّر قَلْبِي مِنَ النِّفَاقِ وَعَمَلِي مِنَ الرِّيَاءِ',
      'اللَّهُمَّ اجعل القرآن رَبِيعَ قَلْبِي وَنُورَ صَدْرِي',
      'اللَّهُمَّ ارزقني حُسن الخاتمة',
      'اللَّهُمَّ ثَبِّتْنِي عِندَ السُّؤَال',
      'اللَّهُمَّ آتِ نَفْسِي تَقْوَاهَا وَزَكِّهَا أَنْتَ خَيْرُ مَنْ زَكَّاهَا',
      'اللَّهُمَّ اجعل قبري رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ',
      'اللَّهُ أَكْبَرُ كَبِيرًا',
      'الحَمْدُ لِلَّهِ كَثِيرًا',
      'سُبْحَانَ اللَّهِ بُكْرَةً وَأَصِيلًا',
      'رَضِيتُ بِاللَّهِ رَبًّا',
      'رَضِيتُ بِالإِسْلاَمِ دِينًا',
      'رَضِيتُ بِمُحَمَّدٍ نَبِيًّا',
      'اللَّهُمَّ زِدْنِي إِيمَانًا',
      'اللَّهُمَّ زِدْنِي هُدًى',
    ];
    final List<SebhaZikrModel> defaultZikrs = defaultZikrTitles
        .map((title) => SebhaZikrModel(zikr: title, count: 33))
        .toList();
    safeEmit(ManageSebhaZikrLoading());
    for (var zikr in defaultZikrs) {
      await SebhaZikrRepo.addZikr(zikr);
    }
    getSebhaZikr();
  }

  Future<void> updateSebhaZikr(int id, SebhaZikrModel zikrModel) async {
    safeEmit(ManageSebhaZikrLoading());
    await SebhaZikrRepo.updateZikr(id, zikrModel);
    getSebhaZikr();
  }

  Future<void> deleteSebhaZikr(int id) async {
    safeEmit(ManageSebhaZikrLoading());
    await SebhaZikrRepo.deleteZikr(id);
    getSebhaZikr();
  }

  void clear() {
    textAddZikr.clear();
    textAddZikrCount.clear();
    formKeyAdd.currentState?.reset();
    formKeyEdit.currentState?.reset();
  }

  @override
  Future<void> close() async {
    textAddZikr.clear();
    textAddZikrCount.clear();
    formKeyAdd.currentState?.reset();
    formKeyEdit.currentState?.reset();
    super.close();
  }
}
