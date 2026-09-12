import 'package:flutter/material.dart';

import '../../../core/utils/date_utils.dart';

class ChartRangeSelector extends StatelessWidget {
  const ChartRangeSelector({super.key, required this.selected, required this.onChanged});

  final ChartRange selected;
  final ValueChanged<ChartRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ChartRange.values.map((range) {
          final isSelected = range == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(range.label),
              selected: isSelected,
              onSelected: (_) => onChanged(range),
            ),
          );
        }).toList(),
      ),
    );
  }
}
