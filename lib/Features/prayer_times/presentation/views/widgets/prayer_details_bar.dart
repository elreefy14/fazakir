import 'package:fazakir/Features/prayer_times/domain/entities/prayer_entity.dart';
import 'package:fazakir/core/enums/prayer_enum.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PrayerDetailsBar extends StatelessWidget {
  const PrayerDetailsBar({
    super.key,
    required this.prayerEntity,
    this.isNextPrayer = false,
  });
  final PrayerEntity prayerEntity;
  final bool isNextPrayer;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNextPrayer
            ? AppColors.primaryColor.withValues(alpha: 0.08)
            : AppColors.greyColor2,
        borderRadius: BorderRadius.circular(10),
        border: isNextPrayer
            ? Border.all(color: AppColors.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            prayerEntity.prayer.iconSVGPath,
            width: 24,
            colorFilter: ColorFilter.mode(
              isNextPrayer ? AppColors.primaryColor : AppColors.textBlackColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            prayerEntity.prayer.arabicName,
            textAlign: TextAlign.right,
            style: AppFontStyles.styleBold14(context).copyWith(
              color: isNextPrayer ? AppColors.primaryColor : null,
            ),
          ),
          if (isNextPrayer) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'القادمة',
                style: AppFontStyles.styleBold10(context).copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            prayerEntity.time,
            textAlign: TextAlign.right,
            style: AppFontStyles.styleBold14(context).copyWith(
              color: isNextPrayer ? AppColors.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
