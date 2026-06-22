import 'package:fazakir/Features/about_religion/domain/entities/video_youtube_entity.dart';
import 'package:fazakir/Features/ahadith/domain/entities/hadith_entity.dart';
import 'package:fazakir/Features/ahadith/presentation/views/widgets/container_hadith_item.dart';
import 'package:fazakir/Features/azkar/domain/entities/azkar_category_favorite_entity.dart';
import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/azkar/presentation/views/zikr_view.dart';
import 'package:fazakir/Features/favorites/domain/entities/favorite_entity.dart';
import 'package:fazakir/Features/favorites/presentation/manager/cubits/cubit/favorites_cubit.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/about_religion_item.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/container_zikr_item.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesViewBody extends StatelessWidget {
  const FavoritesViewBody({super.key});

  Widget _buildContent(BuildContext context, FavoriteEntity fav, double width) {
    if (fav is AzkarCategoryFavoriteEntity) {
      return SizedBox(width: width, child: _FavoriteCategoryCard(entity: fav));
    } else if (fav is VideoYoutubeEntity) {
      return AboutReligionItem(videoYoutubeEntity: fav, width: width);
    } else if (fav is AzkarItemEntity) {
      return SizedBox(
        width: width,
        child: ContainerZikrItem(
          azkarItem: fav,
          margin: EdgeInsets.zero,
          withoutHeader: true,
        ),
      );
    } else if (fav is HadithEntity) {
      return SizedBox(
        width: width,
        child: ContainerHadithItem(hadithEntity: fav),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(
            child: CircularProgressIndicator.adaptive(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
        } else if (state is FavoritesFailure) {
          return Center(child: Text(state.message));
        }

        final cubit = context.read<FavoritesCubit>();
        final List<FavoriteEntity> favList = cubit.favorites;

        if (favList.isEmpty) {
          return const Center(child: Text('لا يوجد مفضلات'));
        }

        return ReorderableListView.builder(
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            HapticFeedback.mediumImpact();
            cubit.reorderFavorites(oldIndex, newIndex);
          },
          padding: const EdgeInsets.only(top: 16, bottom: 110),
          itemCount: favList.length,
          itemBuilder: (context, index) {
            final fav = favList[index];
            return Dismissible(
              key: Key(fav.getIdentifier()),
              direction: DismissDirection.horizontal,
              background: _DeleteBg(fromStart: true),
              secondaryBackground: _DeleteBg(fromStart: false),
              onDismissed: (_) {
                HapticFeedback.lightImpact();
                cubit.toggleFavorite(fav);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── drag handle ──────────────────────────────────────
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 4, end: 2),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          color: Colors.grey.shade400,
                          size: 26,
                        ),
                      ),
                    ),
                    // ── content ──────────────────────────────────────────
                    Expanded(
                      child: LayoutBuilder(
                        builder: (ctx, constraints) =>
                            _buildContent(ctx, fav, constraints.maxWidth),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Delete swipe background ─────────────────────────────────────────────────

class _DeleteBg extends StatelessWidget {
  const _DeleteBg({required this.fromStart});
  final bool fromStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade400,
      alignment: fromStart
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
    );
  }
}

// ── Azkar category card ─────────────────────────────────────────────────────

/// A card shown in the Favorites page for a saved azkar category.
/// Tapping it opens the full list of azkar; the heart removes it from favorites.
class _FavoriteCategoryCard extends StatelessWidget {
  const _FavoriteCategoryCard({required this.entity});
  final AzkarCategoryFavoriteEntity entity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        ZikrView.routeName,
        arguments: entity.toCategory(),
      ),
      child: Container(
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
                entity.categoryName,
                style: AppFontStyles.styleBold16(context).copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Remove from favorites
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<FavoritesCubit>().toggleFavorite(entity);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.redColor,
                  size: 20,
                ),
              ),
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
                '${entity.azkar.length}',
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
