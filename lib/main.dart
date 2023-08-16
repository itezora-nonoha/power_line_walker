import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:power_line_walker/PowerLineData.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late PowerLineData powerLineData = PowerLineData();
  String _appBarTitle = "Power Line Walker";
  String displayType = 'Marker';
  Set<Marker> markerSet = {};
  late Map<String, dynamic> map = json.decode('{"points":[{"latitude":35,"longitude:135,"names":["模擬線-1"]}]}');
  late BitmapDescriptor tower500kV = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor tower154kV = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor tower275kV = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor tower66kV = BitmapDescriptor.defaultMarker;
  late BitmapDescriptor tower275kV154kV = BitmapDescriptor.defaultMarker;
  List<Polyline> powerLineList = [];

  @override
  void initState() {
    super.initState();
    setMarkerImage();
    powerLineData.loadFromJsonFile();
  }

  Future<void> setMarkerImage() async {
    tower500kV = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_500kV.png');
    tower275kV = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_275kV.png');
    tower154kV = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_154kV.png');
    tower66kV = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_66kV.png');
    tower275kV154kV = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_275kV154kV.png');
    setState(() {});
  }

  BitmapDescriptor getTowerIconFromVoltageSet(Set<int> voltageSet) {
    if (setEquals(voltageSet, {275, 154})) {
      return tower275kV154kV;
    } else if (setEquals(voltageSet, {500})) {
      return tower500kV;
    } else if (setEquals(voltageSet, {275})) {
      return tower275kV;
    } else if (setEquals(voltageSet, {154})) {
      return tower154kV;
    } else if (setEquals(voltageSet, {66})) {
      return tower66kV;
    } else {
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<String> loadJsonFile() async {
    map =  powerLineData.getPoints();
    _createMarkerAndPowerLine(map);
    return "complete";
  }

  void _createMarkerAndPowerLine(Map<String, dynamic> map) {
    
    Map<String, List<LatLng>> powerLinePoints = {};

    String powerLineName;
    String name;
    String towerlabel;

    LatLng latlng;
    double latitude, longitude;
    for (var i = 0; i < map['points'].length; i++) {
      towerlabel = map['points'][i]['names'][0];
      latitude = map['points'][i]['latitude'];
      longitude = map['points'][i]['longitude'];
      latlng = LatLng(latitude, longitude);

      for (var ni = 0; ni < map['points'][i]['names'].length; ni++) {
        name = map['points'][i]['names'][ni];
        powerLineName = name.split('-')[0];

        if (powerLinePoints[powerLineName] == null) {
          powerLinePoints[powerLineName] = [];
        }

        powerLinePoints[powerLineName]?.add(latlng);
      }
      // Markerの作成
      var towerIcon = BitmapDescriptor.defaultMarker;

      // その鉄塔における送電電圧リストの作成
      List volList = [];
      for (var ni = 0; ni < map['points'][i]['names'].length; ni++) {
        name = map['points'][i]['names'][ni];
        powerLineName = name.split('-')[0];
        var entry = map['powerLines'].where((e) => e['name'] == powerLineName);
        volList.add(entry.first['transmissionVoltage']);
      }
      map['points'][i]['transmissionVoltageList'] = volList;

      // 送電電圧に応じたMarkerアイコンを取得
      towerIcon = getTowerIconFromVoltageSet(Set.from(volList));

      // Markerを作成し、MarkerSetに追加
      markerSet.add(Marker(
        markerId: MarkerId(towerlabel),
        position: latlng,
        icon: towerIcon,
        visible: true,
        // anchor: const Offset(0.5, 0.5), // バグで機能していないらしい...？ https://github.com/flutter/flutter/issues/80578
      ));
    }

    // マーカークリック時のイベントを設定
    markerSet = markerSet
        .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
        .toSet();

    Color powerLineColor = Colors.blue;
    int transmissionVoltage;

    // 送電系統ごとにPolylineを作成
    for (var name in powerLinePoints.keys) {
      // 送電電圧の取得
      var entry = map['powerLines'].where((e) => e['name'] == name);
      transmissionVoltage = entry.first['transmissionVoltage'];

      // 電圧ごとの色分け
      if (transmissionVoltage == 500) {
        powerLineColor = Colors.red;
      } else if (transmissionVoltage == 275) {
        powerLineColor = Colors.orange;
      } else if (transmissionVoltage == 154) {
        powerLineColor = Colors.green;
      } else if (transmissionVoltage == 66) {
        powerLineColor = Colors.blue;
      }
      
      Polyline p = Polyline(
        polylineId: PolylineId(name),
        points: powerLinePoints[name]!,
        color: powerLineColor,
        width: 5,
      );
      powerLineList.add(p);
    }

    setState(() {});
  }

  void _onTapMarker(Marker marker) {
    setState(() {
      // _appBarTitle = marker.position.toString();
      _appBarTitle = marker.markerId.toString();
    });
  }

  void _changeAppBarTitle(String title) {
    setState(() {
      _appBarTitle = title;
    });
  }

  void _changedCamera(CameraPosition position) {
    setState(() {
      if (position.zoom > 14) {
        displayType = 'Marker';
      } else {
        displayType = 'Line';
      }
    });
  }

  GoogleMap generateGoogleMapWithMarker() {
    return GoogleMap(
        webGestureHandling: WebGestureHandling.greedy,
        zoomGesturesEnabled: true,
        mapType: MapType.hybrid,
        initialCameraPosition: const CameraPosition(
          zoom: 15,
          target: LatLng(35.9522505, 139.6372461),
        ),
        onTap: (LatLng latLng) {
          _changeAppBarTitle(latLng.toString());
        },
        fortyFiveDegreeImageryEnabled: true,
        onCameraMove: (position) => {_changedCamera(position)},
        markers: Set.from(markerSet));
  }

  GoogleMap generateGoogleMapWithPolyLine() {
    return GoogleMap(
      webGestureHandling: WebGestureHandling.greedy,
      zoomGesturesEnabled: true,
      mapType: MapType.hybrid,
      initialCameraPosition: const CameraPosition(
        zoom: 15,
        target: LatLng(35.9522505, 139.6372461),
      ),
      onTap: (LatLng latLng) {
        _changeAppBarTitle(latLng.toString());
      },
      onCameraMove: (position) => {_changedCamera(position)},
      polylines: Set.from(powerLineList),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      
      future: loadJsonFile(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          // var data = snapshot.data;
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.purple,
                title: Text(_appBarTitle),
              ),
              drawer: const Drawer(
                child: Center(
                  child: Text("Drawer")
                )
              ),
            body: (displayType == 'Marker')
            ? generateGoogleMapWithMarker()
            : generateGoogleMapWithPolyLine()
          );
        } else {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.purple,
                title: Text(_appBarTitle),
              ),
              drawer: const Drawer(
                child: Center(
                  child: Text("Drawer")
                )
              ),
              body: const Center(
                  child: Text('処理中...')
              )
          );
        }
      }
    );
  }
}
