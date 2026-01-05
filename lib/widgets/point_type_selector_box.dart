import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_line_walker/id_provider.dart';

class PointTypeSelectorBox extends ConsumerWidget {
  const PointTypeSelectorBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return DropdownButton<String>(
      items: const[
        DropdownMenuItem(
          value: 'tower',
          child: Text('鉄塔'),
        ),
        DropdownMenuItem(
            value: 'substation',
            child: Text('変電所'),
        ),
        DropdownMenuItem(
            value: 'switchyard',
            child: Text('開閉所'),
        ),
        DropdownMenuItem(
            value: 'memo',
            child: Text('地点メモ'),
        ),
      ],
      value: selectedCategory,
      onChanged: (String? value) {
        ref.read(selectedCategoryProvider.notifier).state = value!;
      },
    );
  }
}
