import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/components_zikr_item.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveZikrCard extends StatefulWidget {
  const InteractiveZikrCard({
    super.key,
    required this.azkarItem,
    this.zikrCategory,
    this.onCompleted,
  });

  final AzkarItemEntity azkarItem;
  final String? zikrCategory;
  final VoidCallback? onCompleted;

  @override
  State<InteractiveZikrCard> createState() => _InteractiveZikrCardState();
}

class _InteractiveZikrCardState extends State<InteractiveZikrCard>
    with SingleTickerProviderStateMixin {
  late int _target;
  int _current = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool get _isCompleted => _current >= _target;

  @override
  void initState() {
    super.initState();
    _target = widget.azkarItem.count > 0 ? widget.azkarItem.count : 1;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isCompleted) return;
    HapticFeedback.lightImpact();
    _animController.forward().then((_) => _animController.reverse());
    setState(() => _current++);
    if (_isCompleted) {
      HapticFeedback.mediumImpact();
      widget.onCompleted?.call();
    }
  }

  void _reset() => setState(() => _current = 0);

  @override
  Widget build(BuildContext context) {
    final double progress = _target > 0 ? _current / _target : 0.0;
    final hasSource = widget.azkarItem.source != null &&
        widget.azkarItem.source!.isNotEmpty;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isCompleted
                ? const Color(0xFFEDE4D7)
                : AppColors.quranPagesColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isCompleted
                  ? AppColors.primaryColor
                  : AppColors.primaryColor.withValues(alpha: 0.25),
              width: _isCompleted ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Count / completed badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isCompleted
                            ? AppColors.primaryColor
                            : AppColors.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_current / $_target',
                            style: AppFontStyles.styleBold14(context).copyWith(
                              color: _isCompleted
                                  ? Colors.white
                                  : AppColors.primaryColor,
                            ),
                          ),
                          if (_isCompleted) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 18),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (_isCompleted)
                      InkWell(
                        onTap: _reset,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.refresh,
                              color: AppColors.greyColor, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.azkarItem.text,
                  textAlign: TextAlign.center,
                  style: AppFontStyles.styleRegular20(context).copyWith(
                    fontFamily: 'Amiri',
                    height: 2,
                    color: _isCompleted ? Colors.black54 : Colors.black87,
                  ),
                ),
                if (hasSource) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.azkarItem.source!,
                      textAlign: TextAlign.center,
                      style: AppFontStyles.styleRegular14(context).copyWith(
                        fontFamily: 'Amiri',
                        color: AppColors.primaryColor,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isCompleted ? 'اكتمل' : 'اضغط للتسبيح',
                  style: AppFontStyles.styleRegular13(context).copyWith(
                    color: AppColors.greyColor,
                  ),
                ),
                const SizedBox(height: 4),
                ComponentsZikrItem(zikr: widget.azkarItem),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
