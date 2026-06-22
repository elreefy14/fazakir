import 'dart:io';

import 'package:fazakir/Features/quran/presentation/widgets/verse_image_creator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ShareController extends GetxController {
  static ShareController get instance => Get.find<ShareController>();

  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> shareText(
    String verseText,
    String surahName,
    int verseNumber,
  ) async {
    final String content =
        '﴿ $verseText ﴾\n[$surahName: $verseNumber]\n\nفَذَاكِر - تطبيق المسلم اليومي';
    await Share.share(content, subject: surahName);
  }

  Future<void> shareImage(
    String verseText,
    String surahName,
    int verseNumber,
    int surahNumber,
  ) async {
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        VerseImageCreator(
          verseNumber: verseNumber,
          surahNumber: surahNumber,
          surahName: surahName,
          verseText: verseText,
        ),
        pixelRatio: 3.0,
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/verse_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(imagePath).writeAsBytes(imageBytes);

      final String shareText =
          '﴿ $verseText ﴾\n[$surahName: $verseNumber]\n\nفَذَاكِر - تطبيق المسلم اليومي';

      await Share.shareXFiles([XFile(imagePath)], text: shareText);
    } catch (e) {
      debugPrint('Error sharing image: $e');
      await shareText(verseText, surahName, verseNumber);
    }
  }
}
