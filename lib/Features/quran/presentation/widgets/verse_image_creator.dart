import 'package:flutter/material.dart';

class VerseImageCreator extends StatelessWidget {
  final int verseNumber;
  final int surahNumber;
  final String surahName;
  final String verseText;

  const VerseImageCreator({
    super.key,
    required this.verseNumber,
    required this.surahNumber,
    required this.surahName,
    required this.verseText,
  });

  String _toArabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number
        .toString()
        .split('')
        .map((d) => arabicDigits[int.parse(d)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 960.0,
        decoration: const BoxDecoration(color: Color(0xFF705C42)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF705C42),
                            size: 24,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const Text(
                          'القـرآن الكريــــم\nفَذَاكِر - تطبيق المسلم اليومي',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Almarai',
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            // White card
            Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    // Surah name banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E5D6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF705C42).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'سورة $surahName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Almarai',
                          color: Color(0xFF705C42),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Verse text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 928.0,
                        child: RichText(
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            text:
                                '﴿ $verseText ${_toArabicNumber(verseNumber)} ﴾',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'uthmanic_hafs',
                              color: Color(0xFF161F07),
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
