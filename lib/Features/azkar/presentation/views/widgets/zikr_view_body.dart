import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/azkar/presentation/views/widgets/interactive_zikr_card.dart';

import 'package:flutter/material.dart';

class ZikrViewBody extends StatelessWidget {
  const ZikrViewBody({super.key, required this.azkar});
  final List<AzkarItemEntity> azkar;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        clipBehavior: Clip.none,
        itemCount: azkar.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsetsDirectional.only(
                bottom: index + 1 == azkar.length ? 0 : 16),
            child: InteractiveZikrCard(
              azkarItem: azkar[index],
            ),
          );
        },
      ),
    );
  }
}
