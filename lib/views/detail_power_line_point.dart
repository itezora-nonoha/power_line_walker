import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/repository/power_line_repository.dart';
import 'package:power_line_walker/widgets/point_type_selector_box.dart';

class DetailPowerLinePoint extends ConsumerWidget {
  // AddPowerLinePoint({super.key, required this.title, this.latlng});
  DetailPowerLinePoint({required this.context, required this.powerLinePoint});
  final BuildContext context;
  PowerLinePoint powerLinePoint;

  // @override
  // State<AddPowerLinePoint> createState() => _AddPowerLinePointState();
// }

// class _AddPowerLinePointState extends State<AddPowerLinePoint> {
  final String _userId = 'test';
  final String _pointName = 'test';
  final TextEditingController _controllerLatitude = TextEditingController();
  final TextEditingController _controllerLongitude = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final PointTypeSelectorBox _pointTypeSelectorBox = PointTypeSelectorBox();
  List<PowerLinePoint> _powerLinePointList = [];
  // @override
  // void initState() {
  //   super.initState();
  //     _controllerLatitude.text = latlng!.latitude as String;
  //     _controllerLongitude.text = latlng!.longitude as String;
  // print(super.getLatitude());
  // }

  // @override
  // void dispose() {
  //   _controllerLatitude.dispose();
  //   _controllerLongitude.dispose();
  //   _controllerName.dispose();
  //   super.dispose();
  // }

  // void oneSecondSnackBar(BuildContext context, String message){
  //   if (message.isNotEmpty){
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(message),
  //         duration: Duration(seconds: 1)
  //       )
  //   );
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String _latitude = powerLinePoint.latlng.latitude.toStringAsFixed(7);
    String _longitude = powerLinePoint.latlng.longitude.toStringAsFixed(7);
    String _names = powerLinePoint.names.join(', ');
    _controllerLatitude.text = powerLinePoint.latlng.latitude.toStringAsFixed(7);
    _controllerLongitude.text = powerLinePoint.latlng.longitude.toStringAsFixed(7);
    _controllerName.text = powerLinePoint.names.join(', ');
    return Scaffold(
      appBar: AppBar(
        title: const Text('地点詳細'),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child:Column(
          children: [
            Container(
              width: 1000,
              child: Row(children: [
                Container(
                  child: Text("地点カテゴリ", style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(powerLinePoint.category, style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ])
            ),
            Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: 1000,
              child: Row(children: [
                Container(
                  child: Text("緯度", style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_latitude, style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ])
            ),
            Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: 1000,
              child: Row(children: [
                Container(
                  child: Text("経度", style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_longitude, style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ])
            ),
            Divider(color: Colors.blue, endIndent: 1),
            Container(
              width: 1000,
              child: Row(children: [
                Container(
                  child: Text("鉄塔名", style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
                Container(
                  child: Text(_names, style:TextStyle(fontSize: 24)),
                  height: 50,
                  width: 200,
                ),
              ])
            ),
          ]
        )
      )
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      // home: DetailPowerLinePoint(context: context, powerLinePoint:PowerLinePoint(latlng:LatLng(35.1234567, 135.0987654), names:["東埼玉線-24"], createdAt: DateTime(2025, 01, 01, 12, 34, 56))),
      home: DetailPowerLinePoint(context: context, powerLinePoint:PowerLinePoint(latlng:LatLng(35.1234567, 135.0987654), names:["東埼玉線-24"], createdAt: DateTime(2025, 01, 01, 12, 34, 56), category:'tower')),
    );
  }
}

void main() => runApp(MyApp());
