import 'package:fazakir/Features/quran/presentation/controllers/share_controller.dart';
import 'package:fazakir/Features/quran/presentation/widgets/verse_image_creator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran_library/quran_library.dart';

const _brown = Color(0xFF705C42);

class QuranLibraryView extends StatefulWidget {
  final int? initialPage;

  const QuranLibraryView({super.key, this.initialPage});

  static const String routeName = 'quranLibraryView';

  @override
  State<QuranLibraryView> createState() => _QuranLibraryViewState();
}

class _QuranLibraryViewState extends State<QuranLibraryView> {
  bool isDark = false;
  late ShareController shareController;

  @override
  void initState() {
    super.initState();
    Get.put(ShareController());
    shareController = ShareController.instance;

    if (widget.initialPage != null && widget.initialPage! > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          QuranLibrary().jumpToPage(widget.initialPage!);
        });
      });
    }
  }

  void _showShareOptions(BuildContext context, AyahModel ayah) {
    final surahName = ayah.arabicName ??
        QuranCtrl.instance.surahs
            .firstWhere(
              (s) => s.surahNumber == ayah.surahNumber,
              orElse: () => QuranCtrl.instance.surahs.first,
            )
            .arabicName;
    final ayahText = ayah.text;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetCtx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                    Text(
                      'مشاركة الآية',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 34),
                  ],
                ),
              ),
              const Divider(color: _brown, thickness: 0.5, height: 1),
              const SizedBox(height: 8),
              _buildShareTextSection(
                  context, sheetCtx, ayahText, surahName, ayah.ayahNumber),
              _buildShareImageSection(context, sheetCtx, ayahText, surahName,
                  ayah.ayahNumber, ayah.surahNumber ?? 1),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareTextSection(
    BuildContext context,
    BuildContext sheetCtx,
    String ayahText,
    String surahName,
    int ayahNumber,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(sheetCtx);
          shareController.shareText(ayahText, surahName, ayahNumber);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _brown.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _brown.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.text_fields, color: _brown, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'مشاركة كنص',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '﴿ $ayahText ﴾',
                      style: const TextStyle(
                          fontSize: 13, fontFamily: 'uthmanic_hafs'),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareImageSection(
    BuildContext context,
    BuildContext sheetCtx,
    String ayahText,
    String surahName,
    int ayahNumber,
    int surahNumber,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(sheetCtx);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _brown),
                  SizedBox(height: 16),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      'جاري إنشاء الصورة...',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Almarai'),
                    ),
                  ),
                ],
              ),
            ),
          );
          try {
            await shareController.shareImage(
                ayahText, surahName, ayahNumber, surahNumber);
          } catch (e) {
            debugPrint('Error sharing image: $e');
          }
          if (context.mounted) Navigator.pop(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _brown.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _brown.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.image_outlined, color: _brown, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'مشاركة كصورة',
                      style: TextStyle(
                        fontFamily: 'Almarai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: 960.0,
                          child: VerseImageCreator(
                            verseNumber: ayahNumber,
                            surahNumber: surahNumber,
                            surahName: surahName,
                            verseText: ayahText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: ClipRect(
            child: QuranLibraryScreen(
              showAyahBookmarkedIcon: true,
              ayahSelectedBackgroundColor: _brown.withValues(alpha: 0.15),
              ayahSelectedFontColor: _brown,
              ayahIconColor: _brown,
              bannerStyle: BannerStyle.defaults(isDark: isDark)
                  .copyWith(svgBannerColor: _brown),
              ayahMenuStyle:
                  AyahMenuStyle.defaults(isDark: isDark, context: context)
                      .copyWith(
                showCopyButton: true,
                customMenuItems: [
                  InkWell(
                    onTap: () {
                      if (QuranCtrl
                          .instance.selectedAyahsByUnequeNumber.isNotEmpty) {
                        final selectedUQ = QuranCtrl
                            .instance.selectedAyahsByUnequeNumber.first;
                        final ayah = QuranCtrl.instance.ayahs
                            .firstWhere((a) => a.ayahUQNumber == selectedUQ);
                        Navigator.pop(context);
                        _showShareOptions(context, ayah);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child:
                          Icon(Icons.share_outlined, color: _brown, size: 20),
                    ),
                  ),
                ],
              ),
              appIconPathForPlayAudioInBackground: 'assets/images/app_icon.png',
              parentContext: context,
              isDark: isDark,
              appLanguageCode: 'ar',
              topBarStyle:
                  QuranTopBarStyle.defaults(isDark: isDark, context: context)
                      .copyWith(
                accentColor: _brown,
                iconColor: _brown,
              ),
              onSurahBannerPress: (SurahNamesModel surah) {
                QuranLibrary().getSurahInfoBottomSheet(
                  surahNumber: surah.number,
                  context: context,
                  isDark: isDark,
                );
              },
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: isDark ? Colors.white70 : _brown,
              ),
            ),
          ),
        ),
        // Dark mode toggle
        Positioned(
          bottom: 15,
          left: 5,
          child: FloatingActionButton.small(
            heroTag: 'quran_dark_mode_btn',
            onPressed: () => setState(() => isDark = !isDark),
            backgroundColor:
                isDark ? const Color(0xFF2A2A2A) : Colors.white,
            elevation: 2,
            child: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : _brown,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
