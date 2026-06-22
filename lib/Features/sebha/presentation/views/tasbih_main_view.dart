import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/Features/sebha/presentation/manager/cubits/manage_sebha_zikr_cubit/manage_sebha_zikr_cubit.dart';
import 'package:fazakir/Features/sebha/presentation/views/saved_azkar_view.dart';
import 'package:fazakir/Features/sebha/presentation/views/widgets/tasbih_counter_card.dart';
import 'package:fazakir/core/utils/app_colors.dart';
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
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureKeys(int length) {
    while (_itemKeys.length < length) {
      _itemKeys.add(GlobalKey());
    }
  }

  void _goToNext(int index) {
    final nextIndex = index + 1;
    if (nextIndex >= _itemKeys.length) return;
    final ctx = _itemKeys[nextIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManageSebhaZikrCubit()..addDefaultSebhaZikr(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: BlocBuilder<ManageSebhaZikrCubit, ManageSebhaZikrState>(
              builder: (context, state) {
                final azkar =
                    state is GetAzkarSuccess ? state.azkar : <SebhaZikrModel>[];
                _ensureKeys(azkar.length);

                return Column(
                  children: [
                    const _TasbihHeader(),
                    Expanded(
                      child: azkar.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: azkar.length,
                              itemBuilder: (context, index) => KeyedSubtree(
                                key: _itemKeys[index],
                                child: TasbihCounterCard(
                                  key: ValueKey(azkar[index].id),
                                  zikr: azkar[index],
                                  onCompleted: () => _goToNext(index),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
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
            color: AppColors.primaryColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أذكار محفوظة',
            style: AppFontStyles.styleBold16(context)
                .copyWith(color: AppColors.primaryColor.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط على إدارة الأذكار لإضافة أذكار',
            style: AppFontStyles.styleRegular13(context)
                .copyWith(color: AppColors.primaryColor.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

class _TasbihHeader extends StatelessWidget {
  const _TasbihHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        'فَاذْكُرُونِي أَذْكُرْكُمْ',
        textAlign: TextAlign.center,
        style: AppFontStyles.styleBold20(context).copyWith(
          color: AppColors.primaryColor,
          height: 1.4,
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'إدارة الأذكار',
              style: TextStyle(
                color: Colors.white,
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
