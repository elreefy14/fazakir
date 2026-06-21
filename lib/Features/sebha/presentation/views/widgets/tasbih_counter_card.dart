import 'package:fazakir/Features/sebha/data/models/sebha_zikr_model.dart';
import 'package:fazakir/core/utils/app_font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:vibration/vibration.dart';

class TasbihCounterCard extends StatefulWidget {
  const TasbihCounterCard({super.key, required this.zikr});
  final SebhaZikrModel zikr;

  @override
  State<TasbihCounterCard> createState() => _TasbihCounterCardState();
}

class _TasbihCounterCardState extends State<TasbihCounterCard>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _total;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int get _target => widget.zikr.count > 0 ? widget.zikr.count : 33;
  int get _inCycle => _total.value % _target;
  int get _cycles => _total.value ~/ _target;

  @override
  void initState() {
    super.initState();
    _total = ValueNotifier(0);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _total.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _increment() {
    SystemSound.play(SystemSoundType.click);
    _total.value++;
    _pulseController.forward().then((_) => _pulseController.reverse());
    if (_total.value % _target == 0) {
      _onCycleComplete();
    }
  }

  void _reset() {
    _total.value = 0;
  }

  Future<void> _onCycleComplete() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }
    final hasCustom = await Vibration.hasCustomVibrationsSupport();
    if (hasCustom == true) {
      Vibration.vibrate(duration: 600);
    } else {
      Vibration.vibrate();
      await Future.delayed(const Duration(milliseconds: 500));
      Vibration.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9A7E5E),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.zikr.zikr,
                textAlign: TextAlign.center,
                style: AppFontStyles.styleBold20(context).copyWith(
                  color: Colors.white,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              _CounterDisplay(
                total: _total,
                target: _target,
                pulseAnimation: _pulseAnimation,
                onIncrement: _increment,
              ),
              const SizedBox(height: 24),
              _ActionRow(
                total: _total,
                target: _target,
                onReset: _reset,
                onIncrement: _increment,
                getCycles: () => _cycles,
              ),
              const SizedBox(height: 20),
              _ProgressSection(
                total: _total,
                target: _target,
                getInCycle: () => _inCycle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterDisplay extends StatelessWidget {
  const _CounterDisplay({
    required this.total,
    required this.target,
    required this.pulseAnimation,
    required this.onIncrement,
  });

  final ValueNotifier<int> total;
  final int target;
  final Animation<double> pulseAnimation;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onIncrement,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE0D6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ValueListenableBuilder<int>(
            valueListenable: total,
            builder: (context, value, _) {
              final display = (value % target).toString().padLeft(4, '0');
              return Text(
                display,
                textAlign: TextAlign.center,
                style: AppFontStyles.styleRegular70(context).copyWith(
                  color: const Color(0xFF423428),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.total,
    required this.target,
    required this.onReset,
    required this.onIncrement,
    required this.getCycles,
  });

  final ValueNotifier<int> total;
  final int target;
  final VoidCallback onReset;
  final VoidCallback onIncrement;
  final int Function() getCycles;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ResetButton(onReset: onReset),
        ValueListenableBuilder<int>(
          valueListenable: total,
          builder: (context, value, _) {
            final cycles = getCycles();
            return Column(
              children: [
                Text(
                  'دورات: $cycles',
                  style: AppFontStyles.styleRegular13(context).copyWith(
                    color: Colors.white.withValues(alpha:0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'مجموع: $value',
                  style: AppFontStyles.styleRegular13(context).copyWith(
                    color: Colors.white.withValues(alpha:0.65),
                  ),
                ),
              ],
            );
          },
        ),
        _IncrementButton(onIncrement: onIncrement),
      ],
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onReset,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha:0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'إعادة',
              style: AppFontStyles.styleBold14(context)
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncrementButton extends StatelessWidget {
  const _IncrementButton({required this.onIncrement});
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onIncrement,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha:0.22),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha:0.4), width: 2),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({
    required this.total,
    required this.target,
    required this.getInCycle,
  });

  final ValueNotifier<int> total;
  final int target;
  final int Function() getInCycle;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: total,
      builder: (context, value, _) {
        final inCycle = getInCycle();
        final progress = inCycle / target;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الهدف: $target',
                  style: AppFontStyles.styleRegular11(context).copyWith(
                    color: Colors.white.withValues(alpha:0.7),
                  ),
                ),
                Text(
                  '$inCycle / $target',
                  style: AppFontStyles.styleRegular11(context).copyWith(
                    color: Colors.white.withValues(alpha:0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha:0.18),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 7,
              ),
            ),
          ],
        );
      },
    );
  }
}
