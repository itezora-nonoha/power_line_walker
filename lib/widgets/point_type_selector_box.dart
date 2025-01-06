import 'package:flutter/material.dart';

class PointTypeSelectorBox extends StatefulWidget {
  const PointTypeSelectorBox({Key? key}) : super(key: key);

  @override
  State<PointTypeSelectorBox> createState() => _PointTypeSelectorBoxState();
}

class _PointTypeSelectorBoxState extends State<PointTypeSelectorBox> {
  String isSelectedValue = 'Tower';


  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: const[
        DropdownMenuItem(
          value: 'Tower',
          child: Text('鉄塔'),
        ),
        DropdownMenuItem(
            value: 'Substation',
            child: Text('変電所'),
        ),
        DropdownMenuItem(
            value: 'Switchyard',
            child: Text('開閉所'),
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
