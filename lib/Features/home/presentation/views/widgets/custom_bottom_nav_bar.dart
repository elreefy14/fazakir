import 'package:fazakir/Features/home/presentation/manager/cubits/navigation_cubit/navigation_cubit.dart';
import 'package:fazakir/core/cubits/theme_cubit/theme_cubit.dart';
import 'package:fazakir/core/utils/app_assets.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDark;
    final items = _navItems(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E201E)
              : Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(isDark ? 0.25 : 0.18),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated highlight pill
            _AnimatedHighlight(
              selectedIndex: selectedIndex,
              itemCount: items.length,
              isDark: isDark,
            ),
            // Items row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (i) {
                  return _NavItem(
                    item: items[i],
                    isSelected: selectedIndex == i,
                    onTap: () => context
                        .read<NavigationCubit>()
                        .navigationIndexView(i),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_NavItemData> _navItems(BuildContext context) => [
        _NavItemData(
          svgAsset: Assets.assetsImagesHomeIconSvg,
          label: S.current.your_home,
        ),
        _NavItemData(
          svgAsset: Assets.assetsImagesHeartBlackIconSvg,
          label: S.current.favorites,
        ),
        _NavItemData(
          svgAsset: Assets.assetsImagesAlarmIconSvg,
          label: S.current.prayer_times,
        ),
        _NavItemData(
          svgAsset: Assets.assetsImagesSibhaIconSvg,
          label: S.current.sebha,
        ),
        _NavItemData(
          icon: CupertinoIcons.checkmark_square_fill,
          inactiveIcon: CupertinoIcons.checkmark_square,
          label: 'تتبع الصلوات',
        ),
        _NavItemData(
          svgAsset: Assets.assetsImagesSettingsIconSvg,
          label: S.current.settings,
        ),
      ];
}

// ─── Data model ──────────────────────────────────────────────────────────────
class _NavItemData {
  final String? svgAsset;
  final IconData? icon;
  final IconData? inactiveIcon;
  final String label;

  const _NavItemData({
    this.svgAsset,
    this.icon,
    this.inactiveIcon,
    required this.label,
  });
}

// ─── Animated highlight pill ─────────────────────────────────────────────────
class _AnimatedHighlight extends StatelessWidget {
  const _AnimatedHighlight({
    required this.selectedIndex,
    required this.itemCount,
    required this.isDark,
  });
  final int selectedIndex;
  final int itemCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final itemWidth = constraints.maxWidth / itemCount;
      final left = itemWidth * selectedIndex + itemWidth / 2 - 30;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        left: left,
        child: Container(
          width: 60,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor.withOpacity(isDark ? 0.45 : 0.14),
                AppColors.primaryColor.withOpacity(isDark ? 0.25 : 0.07),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    });
  }
}

// ─── Single nav item ─────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDark;
    final activeColor = AppColors.primaryColor;
    final inactiveColor = isDark
        ? const Color(0xFF666666)
        : const Color(0xFFBBBBBB);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: item.svgAsset != null
                    ? SvgPicture.asset(
                        item.svgAsset!,
                        key: ValueKey(isSelected),
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          isSelected ? activeColor : inactiveColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        isSelected
                            ? (item.icon ?? item.inactiveIcon)
                            : (item.inactiveIcon ?? item.icon),
                        key: ValueKey(isSelected),
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 10 : 9,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : inactiveColor,
                fontFamily: 'Almarai',
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
