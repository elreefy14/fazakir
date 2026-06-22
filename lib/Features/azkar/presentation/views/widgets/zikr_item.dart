import 'package:fazakir/Features/azkar/domain/entities/azkar_category_entity.dart';
import 'package:fazakir/Features/azkar/domain/entities/azkar_category_favorite_entity.dart';
import 'package:fazakir/Features/azkar/presentation/views/zikr_view.dart';
import 'package:fazakir/Features/favorites/presentation/manager/cubits/cubit/favorites_cubit.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';

class ZikrItem extends StatelessWidget {
  const ZikrItem({
    super.key,
    required this.azkarCategory,
  });

  final AzkarCategoryEntity azkarCategory;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () {
        Navigator.pushNamed(
          context,
          ZikrView.routeName,
          arguments: azkarCategory,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF8B7355),
              AppColors.primaryColor,
              Color(0xFF5C4A35),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Category name
            Expanded(
              child: Text(
                azkarCategory.category,
                textAlign: TextAlign.start,
                style: AppFontStyles.styleBold16(context).copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Favourite heart button
            BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                final cubit = context.read<FavoritesCubit>();
                final catEntity =
                    AzkarCategoryFavoriteEntity.fromCategory(azkarCategory);
                final isFav = cubit.favorites.any(
                  (fav) => fav.getIdentifier() == catEntity.getIdentifier(),
                );
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    cubit.toggleFavorite(catEntity);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.redColor : Colors.white,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            // Count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${azkarCategory.azkar.length}',
                style: AppFontStyles.styleBold14(context)
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
