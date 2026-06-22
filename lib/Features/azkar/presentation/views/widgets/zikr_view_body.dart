import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/azkar/presentation/views/widgets/interactive_zikr_card.dart';

import 'package:flutter/material.dart';

class ZikrViewBody extends StatefulWidget {
  const ZikrViewBody({super.key, required this.azkar});
  final List<AzkarItemEntity> azkar;

  @override
  State<ZikrViewBody> createState() => _ZikrViewBodyState();
}

class _ZikrViewBodyState extends State<ZikrViewBody> {
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
    _ensureKeys(widget.azkar.length);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        controller: _scrollController,
        clipBehavior: Clip.none,
        itemCount: widget.azkar.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            key: _itemKeys[index],
            padding: EdgeInsetsDirectional.only(
                bottom: index + 1 == widget.azkar.length ? 0 : 16),
            child: InteractiveZikrCard(
              key: ValueKey(widget.azkar[index].getIdentifier()),
              azkarItem: widget.azkar[index],
              onCompleted: () => _goToNext(index),
            ),
          );
        },
      ),
    );
  }
}
