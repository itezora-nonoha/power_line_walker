import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;
// import 'package:tower/tower.dart';

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
  late Set<Marker> markerSet;
  late BitmapDescriptor pinLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    setMarkerImage();
  }

  Future<void> setMarkerImage() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower_green.png');
    setState(() {});
  }

  Set<Marker> markersVisible = {};
  Set<Marker> markersNotVisible = {};
  Set<Marker> markers = {};
  
  String _data = "Load JSON Data";
  final List<LatLng> _markerLocations = [
    const LatLng(35.9583563, 139.6258101), // 東埼玉線-77
    const LatLng(35.9567532, 139.6271039), // 東埼玉線-78
    const LatLng(35.9552299, 139.6283240), // 東埼玉線-79
    const LatLng(35.9544524, 139.6306582), // 東埼玉線-80
    const LatLng(35.9537335, 139.6327918), // 東埼玉線-81
    const LatLng(35.9530090, 139.6349779), // 東埼玉線-82
    const LatLng(35.9522505, 139.6372461), // 東埼玉線-83
    const LatLng(35.9514831, 139.6395112), // 東埼玉線-84
  ];

  Future<void> loadJsonAsset() async {
    _data = "";
    String loadData = await rootBundle.loadString("asset/higashisaitama.json");
    final jsonResponse = json.decode(loadData);
    jsonResponse.forEach((key,value) => _data = _data + '$key: $value \x0A');
  }


  // void loadTowerInformation() async {
  //   const jsonPath = "asset/higashisaitama.json"; // 好きなパスに変えてください

  //   // シングルトンを取得
  //   final t = Tower();
  //   print('hoge: ${t.hoge}, fuga: ${t.fuga}');

  //   // JSON読み込み
  //   await t.load(jsonPath);
  //   print('hoge: ${t.hoge}, fuga: ${t.fuga}');

  //   // 適当な値を設定
  //   t.hoge = 'hogehoge';
  //   t.fuga = 42;
  //   print('hoge: ${t.hoge}, fuga: ${t.fuga}');

  //   // JSON書き込み
  //   await t.save(jsonPath);
  // }

  // Set<Marker> _createMarker() {
  void _createMarker() {
    _markerLocations.asMap().forEach((i, markerLocation) {
      markersVisible.add(
        Marker(
            markerId: MarkerId('myMarker{$i}'),
            position: markerLocation,
            icon: pinLocationIcon,
            visible: true,
            // anchor: const Offset(0.5, 0.5)),
      ));
    });

    // _markerLocations.asMap().forEach((i, markerLocation) {
    //   markersNotVisible.add(
    //     Marker(
    //         markerId: MarkerId('myMarker{$i}'),
    //         position: markerLocation,
    //         icon: pinLocationIcon,
    //         visible: false),
    //   );
    // });

    // マーカークリック時のイベントを設定
    markersVisible = markersVisible
        .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
        .toSet();
    // markersNotVisible = markersNotVisible
    //     .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
    //     .toSet();
    markerSet = markersVisible;
  }

  // void _switchMarker() {
  //   setState(() {
  //     if (displayType == 'Marker'){
  //       markerSet = markersVisible;
  //     } else {
  //       markerSet = markersNotVisible;
  //       print("test");
  //     }
  //   });
  // }

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
        polylines: {
          Polyline(
            polylineId: PolylineId('line1'),
            points: _markerLocations,
            color: Colors.green,
            width: 5,
          )
        });
  }

  @override
  Widget build(BuildContext context) {
    _createMarker();
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
