import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TasbihCounterCard extends StatefulWidget {
  const TasbihCounterCard({super.key, required this.zikr});
  final SebhaZikrModel zikr;

  @override
  State<TasbihCounterCard> createState() => _TasbihCounterCardState();
}

class _TasbihCounterCardState extends State<TasbihCounterCard> {
  int _count = 0;
  bool _isIncrementPressed = false;
  bool _isResetPressed = false;

  int get _target => widget.zikr.count > 0 ? widget.zikr.count : 33;

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    if (_count % _target == 0) {
      HapticFeedback.mediumImpact();
    }
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _target == 0 ? 0.0 : (_count % _target) / _target;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B7355),
            Color(0xFF705C42),
            Color(0xFF5C4A35),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.zikr.zikr,
            textAlign: TextAlign.center,
            style: AppFontStyles.styleBold20(context).copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _increment,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                _count.toString().padLeft(4, '0'),
                style: AppFontStyles.styleRegular70(context).copyWith(
                  fontSize: 52,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'الهدف: ${_count % _target} / $_target  •  دورات: ${_count ~/ _target}',
            style: AppFontStyles.styleRegular11(context).copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTapDown: (_) => setState(() => _isResetPressed = true),
                onTapUp: (_) {
                  setState(() => _isResetPressed = false);
                  _reset();
                },
                onTapCancel: () => setState(() => _isResetPressed = false),
                child: AnimatedScale(
                  scale: _isResetPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'إعادة',
                          style: AppFontStyles.styleBold14(context)
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTapDown: (_) => setState(() => _isIncrementPressed = true),
                onTapUp: (_) {
                  setState(() => _isIncrementPressed = false);
                  _increment();
                },
                onTapCancel: () =>
                    setState(() => _isIncrementPressed = false),
                child: AnimatedScale(
                  scale: _isIncrementPressed ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
