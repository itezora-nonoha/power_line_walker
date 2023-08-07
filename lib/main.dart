import 'dart:async';
import 'dart:convert';

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
  late BitmapDescriptor pinLocationIcon = BitmapDescriptor.defaultMarker;
  List<Polyline> powerLineList = [];
  @override
  void initState() {
    super.initState();
    setMarkerImage();
    loadJsonAsset();
  }

  Future<void> setMarkerImage() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_green.png');
    setState(() {});
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

        // Markerの作成
        markerSet.add(Marker(
          markerId: MarkerId(towerlabel),
          position: latlng,
          icon: pinLocationIcon,
          visible: true,
          anchor: const Offset(1, 2), // ここで調節
        ));
      }
    }
    // マーカークリック時のイベントを設定
    markerSet = markerSet
        .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
        .toSet();

    Color powerLineColor = Colors.blue;
    var transmissionVoltage = 154;
    // 送電系統ごとにPolylineを作成
    for (var name in powerLinePoints.keys) {
      // 送電電圧の取得
      var entry = map['powerLines'].where((e) => e['name'] == name);  
      transmissionVoltage = entry.first['transmissionVoltage'];

      // 電圧ごとの色分け
      if (transmissionVoltage == 154){
        powerLineColor = Colors.green;
      } else if (transmissionVoltage == 275){
        powerLineColor = Colors.orange;
      };
  
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
        markers: Set.from(markerSet));
  }

  GoogleMap generateGoogleMapWithPolyLine() {
    return GoogleMap(
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
