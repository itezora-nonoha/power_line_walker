import 'package:flutter/material.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/views/edit_power_line_point.dart';

class DetailPowerLinePoint extends StatefulWidget {
  final PowerLinePoint powerLinePoint;
  const DetailPowerLinePoint({super.key, required this.powerLinePoint});

  @override
  State<DetailPowerLinePoint> createState() => _DetailPowerLinePointState();
}

class _DetailPowerLinePointState extends State<DetailPowerLinePoint> {
  late PowerLinePoint _powerLinePoint;

  @override
  void initState() {
    super.initState();
    _powerLinePoint = widget.powerLinePoint;
  }

  void _navigateToEditor(BuildContext context) async {
    final result = await Navigator.push<PowerLinePoint>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPowerLinePoint(powerLinePoint: _powerLinePoint),
      ),
    );
    if (result != null) {
      setState(() {
        _powerLinePoint = result;
      });
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地点詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditor(context),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(children: [
                Container(
                  child: const Text("地点カテゴリ", style: TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_powerLinePoint.category, style: const TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ]),
            ),
            const Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: double.infinity,
              child: Row(children: [
                Container(
                  child: const Text("緯度", style: TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_powerLinePoint.latlng.latitude.toStringAsFixed(7), style: const TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ]),
            ),
            const Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: double.infinity,
              child: Row(children: [
                Container(
                  child: const Text("経度", style: TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_powerLinePoint.latlng.longitude.toStringAsFixed(7), style: const TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ]),
            ),
            const Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: double.infinity,
              child: Row(children: [
                Container(
                  child: const Text("鉄塔名", style: TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_powerLinePoint.names.join(', '), style: const TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
