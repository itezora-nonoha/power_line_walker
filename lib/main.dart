import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;

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
  String _appBarTitle = "Power Line Walker";
  String displayType = 'Marker';
  Set<Marker> markerSet = {};
  late Map<String, dynamic> map;
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
    loadJsonAsset();
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

  // json文字列→jsonオブジェクト
  dynamic stringToObject(String jsonText) {
    dynamic data;

    try {
      data = json.decode(jsonText);
    } catch (e) {
      data = null;
    }
    return data;
  }

  String _gotString = "Load JSON Data";
  String get gotString => this._gotString;

  Future<void> getJsonText(String filePath) async {
    _gotString = await rootBundle.loadString(filePath);
  }

  void loadJsonAsset() {
    getJsonText("assets/higashisaitama.json").then((value) {
      map = json.decode(gotString);
      _createMarkerAndPowerLine(map);
    });
  }

  void _createMarkerAndPowerLine(Map<String, dynamic> map) {
  Map<String, List<LatLng>> powerLinePoints = {};
    // Map<String, BitmapDescriptor> powerLineIcon = {};

    // for (var li = 0; li < map['powerLines'].length; li++) {
    //   var entry = map['powerLines'][li];
    //   String name = entry['name'];
    //   if (entry['transmissionVoltage'] == 154) {
    //     powerLineIcon[name] = tower154kV;
    //   } else if (entry['transmissionVoltage'] == 275) {
    //     powerLineIcon[name] = tower275kV;
    //   }
    // }

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
      // var towerIcon = powerLineIcon[towerlabel.split('-')[0]];
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
        // anchor: const Offset(0.5, 15), // バグで機能していないらしい...？ https://github.com/flutter/flutter/issues/80578
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
    // _createMarker();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(_appBarTitle),
        ),
        drawer: const Drawer(
            child: Center(
          child: Text("Drawer"),
        )),
        body: (displayType == 'Marker')
            ? generateGoogleMapWithMarker()
            : generateGoogleMapWithPolyLine());
  }
}
