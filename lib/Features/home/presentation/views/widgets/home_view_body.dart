import 'package:fazakir/Features/home/presentation/views/shortcuts_view.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/about_religion_column.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/next_prayer_line.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/random_zikr_bloc_builder.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/short_cut_items_list_view.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_cubit.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/manager/prayer_tracker_state.dart';
import 'package:fazakir/Features/prayer_tracker/presentation/widgets/home_prayer_tracker_list.dart';
import 'package:fazakir/Features/search/presentation/views/search_view.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:fazakir/core/widgets/row_label_with_show_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RowLabelWithShowMore(
              labelText: 'الاختصارات',
              onTapShowMore: () =>
                  Navigator.pushNamed(context, ShortCutsView.routeName),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.215,
            child: const ShortCutItemsListView(),
          ),
          const SizedBox(height: 28),
          _buildPrayerTrackerSection(context),
          const SizedBox(height: 28),
          const RandomZikrBlocBuilder(),
          const SizedBox(height: 28),
          const AboutReligionColumn(),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateStr = intl.DateFormat('EEEE، d MMMM yyyy', 'ar').format(now);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF9E835F),
            AppColors.primaryColor,
            Color(0xFF4A3828),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -30, left: -30,
              child: _decorCircle(160, 0.06),
            ),
            Positioned(
              top: 20, right: -20,
              child: _decorCircle(100, 0.05),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // top row: search icon + greeting + date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, SearchView.routeName),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.search,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'مرحباً بك 🌙',
                            style: AppFontStyles.styleBold16(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: AppFontStyles.styleRegular11(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // next prayer single line
                  const NextPrayerLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  // ── Prayer tracker section ─────────────────────────────────────────────

  Widget _buildPrayerTrackerSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<PrayerTrackerCubit, PrayerTrackerState>(
                    builder: (context, state) {
                      if (state is PrayerTrackerLoaded) {
                        final score = state.currentDay.score;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: score == 5
                                ? AppColors.primaryColor
                                : AppColors.primaryColor
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$score / 5',
                            style:
                                AppFontStyles.styleBold14(context).copyWith(
                              color:
                                  score == 5 ? Colors.white : AppColors.primaryColor,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  Text(
                    'صلوات اليوم',
                    style: AppFontStyles.styleBold16(context).copyWith(
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const HomePrayerTrackerList(),
            ],
          ),
        ),
      ),
    );
  }
}
