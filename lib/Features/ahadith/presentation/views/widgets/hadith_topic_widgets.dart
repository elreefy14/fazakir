import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class HadithSectionTitle extends StatelessWidget {
  final String title;
  const HadithSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              title,
              style: AppFontStyles.styleBold16(context).copyWith(
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class HadithCard extends StatefulWidget {
  final String hadith;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const HadithCard({
    super.key,
    required this.hadith,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends State<HadithCard> {
  bool _isPressed = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.hadith));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الحديث',
          style: AppFontStyles.styleBold14(context)
              .copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF9A7E5E),
                Color(0xFF7A6447),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.hadith,
                style: AppFontStyles.styleRegular18(context).copyWith(
                  fontFamily: 'Amiri',
                  color: Colors.white,
                  height: 1.9,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.copy_rounded,
                    label: 'نسخ',
                    onTap: _copyToClipboard,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.share_rounded,
                    label: 'مشاركة',
                    onTap: () => Share.share(widget.hadith),
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: widget.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    label: 'مفضل',
                    onTap: widget.onFavoriteToggle,
                    color: widget.isFavorite ? AppColors.heartRedColor : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFontStyles.styleBold12(context)
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class HadithSectionDivider extends StatelessWidget {
  const HadithSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _line()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryColor.withValues(alpha: 0.5),
              size: 18,
            ),
          ),
          Expanded(child: _line()),
        ],
      ),
    );
  }

  Widget _line() => Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.05),
              AppColors.primaryColor.withValues(alpha: 0.4),
              AppColors.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
      );
}
