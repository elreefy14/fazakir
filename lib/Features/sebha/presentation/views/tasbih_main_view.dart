import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/Features/sebha/presentation/manager/cubits/manage_sebha_zikr_cubit/manage_sebha_zikr_cubit.dart';
import 'package:fazakir/Features/sebha/presentation/views/saved_azkar_view.dart';
import 'package:fazakir/Features/sebha/presentation/views/widgets/tasbih_counter_card.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasbihMainView extends StatefulWidget {
  const TasbihMainView({super.key, this.fromNavigation = false});

  static const String routeName = 'tasbihMainView';
  final bool fromNavigation;

  @override
  State<TasbihMainView> createState() => _TasbihMainViewState();
}

class _TasbihMainViewState extends State<TasbihMainView> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageSebhaZikrCubit()..addDefaultSebhaZikr(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B7355),
                Color(0xFF705C42),
                Color(0xFF5C4A35),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<ManageSebhaZikrCubit, ManageSebhaZikrState>(
              builder: (context, state) {
                final azkar =
                    state is GetAzkarSuccess ? state.azkar : <SebhaZikrModel>[];

                return Column(
                  children: [
                    _TasbihHeader(
                      currentPage: _currentPage,
                      total: azkar.length,
                      onNext: azkar.isNotEmpty && _currentPage < azkar.length - 1
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      onPrev: _currentPage > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              )
                          : null,
                    ),
                    Expanded(
                      child: azkar.isEmpty
                          ? _buildEmptyState(context)
                          : PageView.builder(
                              controller: _pageController,
                              onPageChanged: (page) =>
                                  setState(() => _currentPage = page),
                              itemCount: azkar.length,
                              itemBuilder: (context, index) =>
                                  TasbihCounterCard(zikr: azkar[index]),
                            ),
                    ),
                    if (azkar.isNotEmpty)
                      _PageIndicator(
                        count: azkar.length,
                        currentPage: _currentPage,
                      ),
                    const SizedBox(height: 20),
                    _ManageButton(fromNavigation: widget.fromNavigation),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 64,
            color: Colors.white.withValues(alpha:0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أذكار محفوظة',
            style: AppFontStyles.styleBold16(context)
                .copyWith(color: Colors.white.withValues(alpha:0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على إدارة الأذكار لإضافة أذكار',
            style: AppFontStyles.styleRegular13(context)
                .copyWith(color: Colors.white.withValues(alpha:0.5)),
          ),
        ],
      ),
    );
  }
}

class _TasbihHeader extends StatelessWidget {
  const _TasbihHeader({
    required this.currentPage,
    required this.total,
    required this.onNext,
    required this.onPrev,
  });

  final int currentPage;
  final int total;
  final VoidCallback? onNext;
  final VoidCallback? onPrev;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _NavArrow(icon: Icons.chevron_right_rounded, onTap: onPrev),
          Expanded(
            child: Column(
              children: [
                Text(
                  'فَاذْكُرُونِي أَذْكُرْكُمْ',
                  textAlign: TextAlign.center,
                  style: AppFontStyles.styleBold20(context).copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${currentPage + 1} / $total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.65),
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _NavArrow(icon: Icons.chevron_left_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap != null ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha:0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.currentPage});
  final int count;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha:0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  const _ManageButton({required this.fromNavigation});
  final bool fromNavigation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, SavedAzkarView.routeName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha:0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded,
                color: Colors.white.withValues(alpha:0.85), size: 18),
            const SizedBox(width: 8),
            Text(
              'إدارة الأذكار',
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.85),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
