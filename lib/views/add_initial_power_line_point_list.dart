import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/db/PowerLinePointHelper.dart';
import 'package:power_line_walker/models/PowerLinePoint.dart';
import 'package:power_line_walker/views/power_line_map.dart';

class AddInitialPowerLinePointList {

  Map<String, dynamic> map = {};
  Future<String> loadFromJsonFile() async {
  // Future<Map<String, dynamic>?> loadJsonFile() async {
    String str;
    str = await rootBundle.loadString("assets/higashisaitama.json");
    map = json.decode(str);
    return "complete";
  }

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
  
  void addPowerLinePoint(LatLng latlng, String names) async {
    final PowerLinePoint powerLinePoint =
        PowerLinePoint(latlng: latlng, names: names, createdAt: DateTime.now());
    await PowerLinePointHelper.instance.insert(powerLinePoint);
    _powerLinePointList.add(powerLinePoint);
    print(powerLinePoint);
    // setState(() {});
  }
}


void main(){
  AddInitialPowerLinePointList pointList = AddInitialPowerLinePointList();
  // pointList.loadFromJsonFile();
  pointList.addPowerLinePoint(LatLng(35.9695359, 139.6168301), '東埼玉線-71');
}
