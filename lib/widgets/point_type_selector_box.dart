import 'package:flutter/material.dart';

class PointTypeSelectorBox extends StatefulWidget {
  const PointTypeSelectorBox({Key? key}) : super(key: key);

  @override
  State<PointTypeSelectorBox> createState() => _PointTypeSelectorBoxState();
}

class _PointTypeSelectorBoxState extends State<PointTypeSelectorBox> {
  String isSelectedValue = 'tower';

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
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
      value: isSelectedValue,
      onChanged: (String? value) {
        setState(() {
          isSelectedValue = value!;
        });
      },
    );
  }
}
