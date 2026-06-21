import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/azkar/presentation/manager/cubits/manage_azkar_cubit/manage_azkar_cubit.dart';
import 'package:fazakir/Features/home/presentation/views/widgets/container_zikr_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RandomZikrBlocBuilder extends StatelessWidget {
  const RandomZikrBlocBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageAzkarCubit, ManageAzkarState>(
      builder: (context, state) {
        if (state is FetchAzkarSuccess) {
          return ContainerZikrItem(
            azkarItem: state.azkarCategories.first.azkar.first,
            zikrCategory: state.azkarCategories.first.category,
            withoutCount: true,
          );
        } else if (state is FetchAzkarLoading) {
          return const _PulseLoadingPlaceholder();
        } else {
          return ContainerZikrItem(
            azkarItem: AzkarItemEntity(
              id: 1,
              text:
                  'اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.',
              count: 1,
            ),
            withoutCount: true,
          );
        }
      },
    );
  }
}

class _PulseLoadingPlaceholder extends StatefulWidget {
  const _PulseLoadingPlaceholder();

  @override
  State<_PulseLoadingPlaceholder> createState() =>
      _PulseLoadingPlaceholderState();
}

class _PulseLoadingPlaceholderState extends State<_PulseLoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}
