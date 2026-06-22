import 'package:fazakir/Features/ahadith/presentation/data/hadith_sections_data.dart';
import 'package:fazakir/Features/ahadith/presentation/views/widgets/hadith_topic_widgets.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HadithTopicsView extends StatefulWidget {
  const HadithTopicsView({super.key});
  static const String routeName = 'hadithTopicsView';

  @override
  State<HadithTopicsView> createState() => _HadithTopicsViewState();
}

class _HadithTopicsViewState extends State<HadithTopicsView> {
  final ScrollController _scrollController = ScrollController();
  List<MapEntry<String, List<String>>> _displayedSections = [];
  Set<String> _favorites = {};
  String? _selectedCategory;
  int _currentLength = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _updateDisplayedSections();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_hadiths') ?? [];
    if (mounted) setState(() => _favorites = favorites.toSet());
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_hadiths', _favorites.toList());
  }

  void _toggleFavorite(String hadith) {
    setState(() {
      if (_favorites.contains(hadith)) {
        _favorites.remove(hadith);
      } else {
        _favorites.add(hadith);
      }
    });
    _saveFavorites();
  }

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

  void _showFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HadithFavoritesView(
          favorites: _favorites,
          onRemove: _toggleFavorite,
        ),
      ),
    ).then((_) => setState(() {}));
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
                          style: AppFontStyles.styleBold12(context).copyWith(
                            color: isSelected ? Colors.white : Colors.black54,
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0EA),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            if (_selectedCategory != null) _buildFilterChip(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _displayedSections.length + (_isLoading ? 1 : 0),
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
                            isFavorite: _favorites.contains(hadith),
                            onFavoriteToggle: () => _toggleFavorite(hadith),
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
  }

  PreferredSizeWidget _buildAppBar() {
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
        style: AppFontStyles.styleBold20(context).copyWith(color: Colors.white),
      ),
      leading: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          if (_selectedCategory != null)
            const Positioned(
              right: 8,
              top: 8,
              child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
            ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: Colors.white),
              onPressed: _showFavorites,
            ),
            if (_favorites.isNotEmpty)
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
                    '${_favorites.length}',
                    style: AppFontStyles.styleBold10(context)
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white),
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

class HadithFavoritesView extends StatefulWidget {
  final Set<String> favorites;
  final void Function(String) onRemove;

  const HadithFavoritesView({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  State<HadithFavoritesView> createState() => _HadithFavoritesViewState();
}

class _HadithFavoritesViewState extends State<HadithFavoritesView> {
  late Set<String> _local;

  @override
  void initState() {
    super.initState();
    _local = Set.from(widget.favorites);
  }

  void _handleRemove(String hadith) {
    setState(() => _local.remove(hadith));
    widget.onRemove(hadith);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0EA),
        appBar: AppBar(
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
            'الأحاديث المفضلة',
            style: AppFontStyles.styleBold20(context)
                .copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: _local.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'لا توجد أحاديث مفضلة',
              style: AppFontStyles.styleBold20(context)
                  .copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'قم بإضافة الأحاديث التي تعجبك إلى المفضلة\nبالضغط على أيقونة القلب',
              style: AppFontStyles.styleRegular14(context)
                  .copyWith(color: Colors.grey.shade600, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    final list = _local.toList();
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_rounded,
                  size: 20, color: AppColors.heartRedColor),
              const SizedBox(width: 8),
              Text(
                'لديك ${list.length} حديث مفضل',
                style: AppFontStyles.styleBold14(context)
                    .copyWith(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final hadith = list[index];
              return HadithCard(
                hadith: hadith,
                isFavorite: true,
                onFavoriteToggle: () => _handleRemove(hadith),
              );
            },
          ),
        ),
      ],
    );
  }
}
