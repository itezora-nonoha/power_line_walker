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
  dynamic jsonDict;
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
  List<LatLng> powerLinePoints = [];

  Future<void> getJsonText(String filePath) async {
    _gotString = await rootBundle.loadString(filePath);
  }

  // String get gotString => this._data;
  void loadJsonAsset() {
    getJsonText("assets/higashisaitama.json").then((value) {
      map = json.decode(gotString);
      _createMarker(map);
      for (var i = 0; i < map['points'].length; i++) {
        double latitude, longitude;
        latitude = map['points'][i]['latitude'];
        longitude = map['points'][i]['longitude'];

        powerLinePoints.add(LatLng(latitude, longitude));
        // markerSet.add(Marker(
        //   markerId: MarkerId(map['points'][i]['name']),
        //   position: LatLng(latitude, longitude),
        //   icon: pinLocationIcon,
        //   visible: true,
        // ));
        Polyline p = Polyline(
          polylineId: PolylineId('higashiSaitama'),
          points: powerLinePoints,
          color: Colors.green,
          width: 5,
        );
        powerLineList.add(p);
      }
    });
  }

  // Set<Marker> _createMarker() {
  void _createMarker(Map<String, dynamic> map) {

    for (var i = 0; i < map['points'].length; i++) {
      double latitude, longitude;
      latitude = map['points'][i]['latitude'];
      longitude = map['points'][i]['longitude'];

      markerSet.add(Marker(
        markerId: MarkerId(map['points'][i]['name']),
        position: LatLng(latitude, longitude),
        icon: pinLocationIcon,
        visible: true,
      ));
    }

    // マーカークリック時のイベントを設定
    markerSet = markerSet
        .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
        .toSet();
  }

  void _onTapMarker(Marker marker) {
    setState(() {
      _appBarTitle = marker.position.toString();
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
