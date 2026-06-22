import 'package:fazakir/Features/settings/data/model/settings_list_model.dart';
import 'package:fazakir/Features/settings/presentation/widgets/app_creators.dart';
import 'package:fazakir/core/utils/app_assets.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:fazakir/core/utils/func/helper_funcs.dart';
import 'package:fazakir/core/widgets/custom_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsViewBody extends StatefulWidget {
  const SettingsViewBody({super.key});

  @override
  State<SettingsViewBody> createState() => _SettingsViewBodyState();
}

class _SettingsViewBodyState extends State<SettingsViewBody> {
  bool _creatorsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...getSettingsList(context, onCreatorsTap: () {
              setState(() {
                _creatorsExpanded = !_creatorsExpanded;
              });
            }).map((e) => e.buildList(context)),
            const SizedBox(height: 6),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _creatorsExpanded
                  ? const AppCreators()
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: ShapeDecoration(
                color: const Color(0xFFF0F7F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(
                    color: Color(0xFFB2D8B2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '🤲 صدقة جارية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'هذا التطبيق صدقة جارية على روح',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'المستشار ماهر منسي',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'نسأل الله أن يتغمده بواسع رحمته\nويجعل هذا العمل في ميزان حسناته.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextButton(
              onPressed: () {
                shareApp(context);
              },
              padding: const EdgeInsets.all(14),
              text: '',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SvgPicture.asset(Assets.assetsImagesStarIconSvg),
                  Text(
                    'شارك التجربة مع الاصدقاء',
                    style: AppFontStyles.styleBold14(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SvgPicture.asset(Assets.assetsImagesStarIconSvg),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}
