import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/db/PowerLinePointHelper.dart';
import 'package:power_line_walker/models/PowerLinePoint.dart';
import 'package:power_line_walker/views/power_line_map.dart';

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

  void _addPowerLinePoint(LatLng latlng, String names) async {
    final PowerLinePoint powerLinePoint =
        PowerLinePoint(latlng: latlng, names: names, createdAt: DateTime.now());
    await PowerLinePointHelper.instance.insert(powerLinePoint);
    _powerLinePointList.add(powerLinePoint);
    print(powerLinePoint);
    // setState(() {});
  }

  void _saveButtonPushed(){
    var latitude = double.parse(_controllerLatitude.text);
    var longitude = double.parse(_controllerLongitude.text);
    var latLng = LatLng(latitude, longitude);
    var name = _controllerName.text;
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('OnTapped: ${name}, ${latLng.toString()}'),
    //   duration: const Duration(seconds: 1),
    // ));
    _addPowerLinePoint(latLng, name);
  }

  @override
  Widget build(BuildContext context) {
    _controllerLatitude.text = latlng!.latitude.toStringAsFixed(7);
    _controllerLongitude.text = latlng!.longitude.toStringAsFixed(7);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Expanded(
                  child: TextField(
                controller: _controllerLatitude,
                autofocus: false,
                decoration: const InputDecoration(labelText: 'latitude'),
              )),
              Expanded(
                  child: TextField(
                controller: _controllerLongitude,
                autofocus: false,
                decoration: const InputDecoration(labelText: 'longitude'),
              )),
              Expanded(
                  child: TextField(
                controller: _controllerName,
                autofocus: false,
                decoration: const InputDecoration(labelText: 'name'),
                onSubmitted: (String value) {
                  double latitude = double.parse(_controllerLatitude.text);
                  double longitude = double.parse(_controllerLongitude.text);
                  LatLng latlng = LatLng(latitude, longitude);
                  print(latlng);
                  _addPowerLinePoint(latlng, _controllerName.text);
                  _controllerLatitude.clear();
                  _controllerLongitude.clear();
                  _controllerName.clear();
                },
              )),
              SizedBox(
                width: 50,
                height: 25,
                child: ElevatedButton(
                    onPressed: () {
                      _saveButtonPushed();
                      // _getPowerLinePoint(powerLinePoint.names);
                    },
                    child: const Icon(
                      Icons.book,
                      size: 15,
                    )),
              ),
            ])));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.title),
  //     ),
  //     body: SafeArea(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: SizedBox(
  //               child: _powerLinePointList.isEmpty
  //                   ? const Center(child: Text('NO DATA'))
  //                   : ListView.builder(
  //                       itemCount: _powerLinePointList.length,
  //                       itemBuilder: (BuildContext context, int index) {
  //                         final powerLinePoint = _powerLinePointList[index];
  //                         return Card(
  //                           child: InkWell(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Row(
  //                                 children: <Widget>[
  //                                   Expanded(
  //                                     child: Text(
  //                                       powerLinePoint.names,
  //                                       style: const TextStyle(fontSize: 16),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Text(
  //                                       powerLinePoint.latlng.latitude.toString(),
  //                                       style: const TextStyle(fontSize: 16),
  //                                     ),
  //                                   ),
  //                                   Expanded(
  //                                     child: Text(
  //                                       powerLinePoint.latlng.longitude.toString(),
  //                                       style: const TextStyle(fontSize: 16),
  //                                     ),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 50,
  //                                     height: 25,
  //                                     child: ElevatedButton(
  //                                         onPressed: () {
  //                                           _getPowerLinePoint(powerLinePoint.names);
  //                                         },
  //                                         child: const Icon(
  //                                           Icons.book,
  //                                           size: 15,
  //                                         )),
  //                                   ),
  //                                   const SizedBox(
  //                                     width: 5,
  //                                     height: 25,
  //                                   ),
  //                                   SizedBox(
  //                                     width: 50,
  //                                     height: 25,
  //                                     child: ElevatedButton(
  //                                         onPressed: () {
  //                                           _deletePowerLinePoint(powerLinePoint.names, index);
  //                                         },
  //                                         child: const Icon(
  //                                           Icons.delete,
  //                                           size: 15,
  //                                         )),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           ),
  //                         );
  //                       }),
  //             ),
  //           ),
  //           Row(
  //             children: [
  //               Expanded(
  //                   child: TextField(
  //                 controller: _controllerLatitude,
  //                 autofocus: false,
  //                 decoration: const InputDecoration(labelText: 'latitude'),
  //               )),
  //               Expanded(
  //                   child: TextField(
  //                 controller: _controllerLongitude,
  //                 autofocus: false,
  //                 decoration: const InputDecoration(labelText: 'longitude'),
  //               )),
  //               Expanded(
  //                   child: TextField(
  //                 controller: _controllerName,
  //                 autofocus: false,
  //                 decoration: const InputDecoration(labelText: 'name'),
  //                 onSubmitted: (String value) {
  //                   double latitude = double.parse(_controllerLatitude.text);
  //                   double longitude = double.parse(_controllerLongitude.text);
  //                   LatLng latlng = LatLng(latitude, longitude);
  //                   print(latlng);
  //                   _addPowerLinePoint(latlng, _controllerName.text);_controllerLatitude.clear();
  //                   _controllerLongitude.clear();
  //                   _controllerName.clear();
  //                 },
  //               )),
  //               ElevatedButton(
  //                   onPressed: () {
  //                   double latitude = double.parse(_controllerLatitude.text);
  //                   double longitude = double.parse(_controllerLongitude.text);
  //                   LatLng latlng = LatLng(latitude, longitude);
  //                   print(latlng);
  //                   _addPowerLinePoint(latlng, _controllerName.text);
  //                   _controllerLatitude.clear();
  //                   _controllerLongitude.clear();
  //                   _controllerName.clear();
  //                 },
  //                   child: const Icon(Icons.add)),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
