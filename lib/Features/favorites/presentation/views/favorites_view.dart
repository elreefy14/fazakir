import 'package:fazakir/Features/favorites/presentation/manager/cubits/cubit/favorites_cubit.dart';
import 'package:fazakir/Features/favorites/presentation/views/widgets/favorites_view_body.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<FavoritesCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'مسح المفضلة',
          textAlign: TextAlign.center,
          style: AppFontStyles.styleBold16(context)
              .copyWith(color: AppColors.primaryColor),
        ),
        content: Text(
          'هل تريد مسح كل المفضلة؟',
          textAlign: TextAlign.center,
          style: AppFontStyles.styleRegular14(context),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: AppFontStyles.styleBold14(context)
                  .copyWith(color: AppColors.greyColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'مسح',
              style: AppFontStyles.styleBold14(context)
                  .copyWith(color: AppColors.redColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.clearAllFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المفضلة',
          style: AppFontStyles.styleBold20(context),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final hasItems =
                  context.read<FavoritesCubit>().favorites.isNotEmpty;
              if (!hasItems) return const SizedBox();
              return IconButton(
                tooltip: 'مسح الكل',
                onPressed: () => _confirmClear(context),
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: AppColors.redColor,
                ),
              );
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: FavoritesViewBody(),
      ),
    );
  }
}
