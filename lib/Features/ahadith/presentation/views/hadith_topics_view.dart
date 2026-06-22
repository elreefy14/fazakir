import 'package:fazakir/Features/ahadith/domain/entities/hadith_entity.dart';
import 'package:fazakir/Features/ahadith/presentation/data/hadith_sections_data.dart';
import 'package:fazakir/Features/ahadith/presentation/views/widgets/hadith_topic_widgets.dart';
import 'package:fazakir/Features/favorites/presentation/manager/cubits/cubit/favorites_cubit.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HadithTopicsView extends StatefulWidget {
  const HadithTopicsView({super.key});
  static const String routeName = 'hadithTopicsView';

  @override
  State<HadithTopicsView> createState() => _HadithTopicsViewState();
}

class _HadithTopicsViewState extends State<HadithTopicsView> {
  final ScrollController _scrollController = ScrollController();
  List<MapEntry<String, List<String>>> _displayedSections = [];
  String? _selectedCategory;
  int _currentLength = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _updateDisplayedSections();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Favorites helpers ──────────────────────────────────────────────────────

  /// Build a HadithEntity from a plain-text topic hadith.
  HadithEntity _toEntity(String hadith, String sectionTitle) {
    return HadithEntity.create(
      hadith: hadith,
      bookName: 'أحاديث الموضوعات',
      sectionOfBookHadith: sectionTitle,
      hadithNumber: hadith.hashCode.toString(),
      grades: [],
    );
  }

  bool _isFavorite(String hadith, FavoritesCubit cubit) {
    return cubit.favorites.any(
      (fav) => fav is HadithEntity && fav.hadith == hadith,
    );
  }

  void _toggleFavorite(
      String hadith, String sectionTitle, FavoritesCubit cubit) {
    cubit.toggleFavorite(_toEntity(hadith, sectionTitle));
  }

  // ── Scroll / filter ───────────────────────────────────────────────────────

  void _updateDisplayedSections() {
    setState(() {
      if (_selectedCategory == null) {
        _displayedSections =
            hadithSections.entries.take(_currentLength).toList();
      } else {
        _displayedSections = hadithSections.entries
            .where((entry) => entry.key == _selectedCategory)
            .toList();
      }
    });
  }

  void _onScroll() {
    if (_selectedCategory != null) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoading || _selectedCategory != null) return;
    if (_currentLength >= hadithSections.length) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        int nextLength = _currentLength + 3;
        if (nextLength > hadithSections.length) {
          nextLength = hadithSections.length;
        }
        _currentLength = nextLength;
        _updateDisplayedSections();
        _isLoading = false;
      });
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F0EA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'اختر القسم',
                      style: AppFontStyles.styleBold20(ctx)
                          .copyWith(color: AppColors.primaryColor),
                    ),
                    if (_selectedCategory != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _currentLength = 3;
                            _updateDisplayedSections();
                          });
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.primaryColor),
                        label: Text(
                          'مسح الفلتر',
                          style: AppFontStyles.styleBold14(ctx)
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: hadithSections.length,
                  itemBuilder: (context, index) {
                    final category = hadithSections.keys.elementAt(index);
                    final isSelected = category == _selectedCategory;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      leading: Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.grey.shade400,
                      ),
                      title: Text(
                        category,
                        style: AppFontStyles.styleBold14(context).copyWith(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.black87,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${hadithSections[category]!.length}',
                          style:
                              AppFontStyles.styleBold12(context).copyWith(
                            color:
                                isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                          _updateDisplayedSections();
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final cubit = context.read<FavoritesCubit>();
        final favCount = cubit.favorites.whereType<HadithEntity>().length;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F0EA),
            appBar: _buildAppBar(favCount),
            body: Column(
              children: [
                if (_selectedCategory != null) _buildFilterChip(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        _displayedSections.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _displayedSections.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }
                      final sectionTitle = _displayedSections[index].key;
                      final hadiths = _displayedSections[index].value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HadithSectionTitle(title: sectionTitle),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: hadiths.length,
                            itemBuilder: (context, i) {
                              final hadith = hadiths[i];
                              return HadithCard(
                                hadith: hadith,
                                isFavorite: _isFavorite(hadith, cubit),
                                onFavoriteToggle: () => _toggleFavorite(
                                    hadith, sectionTitle, cubit),
                              );
                            },
                          ),
                          const HadithSectionDivider(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(int favCount) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B7355), AppColors.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        'الأحاديث النبوية',
        style:
            AppFontStyles.styleBold20(context).copyWith(color: Colors.white),
      ),
      leading: Stack(
        children: [
          IconButton(
            icon:
                const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          if (_selectedCategory != null)
            const Positioned(
              right: 8,
              top: 8,
              child:
                  CircleAvatar(radius: 4, backgroundColor: Colors.red),
            ),
        ],
      ),
      actions: [
        // Shows count of favorited hadiths from FavoritesCubit
        Stack(
          children: [
            const IconButton(
              icon: Icon(Icons.favorite_rounded, color: Colors.white),
              onPressed: null, // go to main favorites via bottom nav
            ),
            if (favCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$favCount',
                    style: AppFontStyles.styleBold10(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildFilterChip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded,
              size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'القسم: $_selectedCategory',
              style: AppFontStyles.styleBold14(context)
                  .copyWith(color: AppColors.primaryColor),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _selectedCategory = null;
                _currentLength = 3;
                _updateDisplayedSections();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
