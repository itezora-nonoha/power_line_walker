import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/views/power_line_repository.dart';
import 'package:power_line_walker/widgets/point_type_selector_box.dart';

class AddPowerLinePoint extends StatelessWidget {
  // AddPowerLinePoint({super.key, required this.title, this.latlng});
  AddPowerLinePoint({required this.context, this.latlng});
  final BuildContext context;
  LatLng? latlng;

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

  // 「地点登録」ボタン押下時の操作
  int _saveButtonPushed() {
    bool isValidInputData = true;
    bool isValidInputName = true;

    double latitude;
    double longitude;
    
    try {
      latitude = double.parse(_controllerLatitude.text);
      longitude = double.parse(_controllerLongitude.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[入力エラー] 緯度(latitude) または 経度(longitude) を数値に変換することができません。'),
        duration: const Duration(seconds: 1),
      ));
      return 1;
    }

    var latlng = LatLng(latitude, longitude);
    var names = _controllerName.text.split(',');
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('OnTapped: ${name}, ${latLng.toString()}'),
    //   duration: const Duration(seconds: 1),
    // ));

    if (latitude < -180 || latitude > 180){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[入力エラー] 緯度(latitude) は「-180以上 180未満」である必要があります。'),
        duration: const Duration(seconds: 2),
      ));
       isValidInputData = false;
    }
    if (latitude < -180 || latitude > 180){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[入力エラー] 経度(longitude) は「-180以上 180未満」である必要があります。'),
        duration: const Duration(seconds: 2),
      ));
       isValidInputData = false;
    }

    if (names.length == 0){
        isValidInputName = false;
    } else {
      for (var n in names) {
        var splitName = n.split('-');
        if (splitName.length < 2){
          isValidInputName = false;
        }
      }
    }
  
    if (isValidInputName == false){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('[入力エラー] 地点名リスト(names)が適切に入力されていません。'),
        duration: const Duration(seconds: 2),
      ));
    }

    if (isValidInputData && isValidInputName){
      _addPowerLinePoint(latlng, names);
      _controllerLatitude.clear();
      _controllerLongitude.clear();
      _controllerName.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('地点登録が完了しました。($latlng ... $names)'),
        duration: const Duration(seconds: 1),
      ));
      return 0;
    } else {
      return -1;
    }
  }

  void _addPowerLinePoint(LatLng latlng, List<String> names) async {
    final PowerLinePoint powerLinePoint =
        PowerLinePoint(latlng: latlng, names: names, createdAt: DateTime.now());
    await PowerLineRepository.instance.insert(powerLinePoint);
    _powerLinePointList.add(powerLinePoint);
    
  }

  @override
  Widget build(BuildContext context) {
    _controllerLatitude.text = latlng!.latitude.toStringAsFixed(7);
    _controllerLongitude.text = latlng!.longitude.toStringAsFixed(7);
    return Scaffold(
        appBar: AppBar(
          title: const Text('地点登録'),
        ),
        body: Container(
            margin: const EdgeInsets.all(8),
            child: Column(children: [
              // Row(mainAxisSize: MainAxisSize.max,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                // Expanded(child:
                TextField(
                  controller: _controllerLatitude,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: 'latitude'),
                ),
                // ),
                // const SizedBox(width: 10, child: Spacer()),
                // Expanded(child: 
                    TextField(
                  controller: _controllerLongitude,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: 'longitude'),
                ),
                // ),
              // ]),
              TextField(
                controller: _controllerName,
                autofocus: false,
                decoration: const InputDecoration(labelText: 'name(併架はカンマ区切りで入力)'),
                onSubmitted: (String value) {
                  _saveButtonPushed();
                },
              ),
              _pointTypeSelectorBox,
              Container(
                  margin: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: 100,
                    // width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                        onPressed: () {
                          var returnCode = _saveButtonPushed();
                          if (returnCode == 0) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("地点登録")
                        // const Icon(Icons.book,size: 15),
                        ),
                  )),
            ])));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: AddPowerLinePoint(context: context, latlng: const LatLng(35, 135)),
    );
  }
}

void main() => runApp(MyApp());
