import 'package:fazakir/Features/quran/presentation/manager/cubits/quran_cubit/quran_cubit.dart';
import 'package:fazakir/core/utils/app_colors.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';

class SearchInQuranLoadingWidget extends StatelessWidget {
  const SearchInQuranLoadingWidget({
    super.key,
    required this.quranCubit,
  });

  final QuranCubit quranCubit;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) ...[
                  Text(
                    'الآيات'
                    ' (${quranCubit.ayat.length})',
                    style: AppFontStyles.styleBold16(context),
                  ),
                  const SizedBox(height: 12),
                ],
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: 16,
                  ),
                  child: _ShimmerPlaceholder(
                    height: 72,
                    baseColor: AppColors.greyColor,
                    highlightColor: AppColors.greyColor2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder({
    required this.height,
    required this.baseColor,
    required this.highlightColor,
  });

  final double height;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}
