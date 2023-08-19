import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/db/PowerLinePointHelper.dart';
import 'package:power_line_walker/models/PowerLinePoint.dart';
import 'package:power_line_walker/widgets/point_type_selector_box.dart';

class AddPowerLinePoint extends StatelessWidget {
  // AddPowerLinePoint({super.key, required this.title, this.latlng});
  AddPowerLinePoint({required this.title, this.latlng});
  final String title;
  LatLng? latlng;

//   @override
//   State<AddPowerLinePoint> createState() => _AddPowerLinePointState();
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

  void _saveButtonPushed() {
    var latitude = double.parse(_controllerLatitude.text);
    var longitude = double.parse(_controllerLongitude.text);
    var latlng = LatLng(latitude, longitude);
    var name = _controllerName.text;
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('OnTapped: ${name}, ${latLng.toString()}'),
    //   duration: const Duration(seconds: 1),
    // ));
    _addPowerLinePoint(latlng, name);
    _controllerLatitude.clear();
    _controllerLongitude.clear();
    _controllerName.clear();

  }

  void _addPowerLinePoint(LatLng latlng, String names) async {
    final PowerLinePoint powerLinePoint =
        PowerLinePoint(latlng: latlng, names: names, createdAt: DateTime.now());
    await PowerLinePointHelper.instance.insert(powerLinePoint);
    _powerLinePointList.add(powerLinePoint);
  }

  @override
  Widget build(BuildContext context) {
    _controllerLatitude.text = latlng!.latitude.toStringAsFixed(7);
    _controllerLongitude.text = latlng!.longitude.toStringAsFixed(7);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
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
                decoration: const InputDecoration(labelText: 'name'),
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
                          _saveButtonPushed();
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
      home: AddPowerLinePoint(title: 'test', latlng: const LatLng(35, 135)),
    );
  }
}

void main() => runApp(MyApp());
