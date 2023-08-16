import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:power_line_walker/firebase_options.dart';

import 'package:power_line_walker/PowerLineData.dart';
import 'package:power_line_walker/db/PowerLinePointHelper.dart';
import 'package:power_line_walker/models/PowerLinePoint.dart';
import 'package:power_line_walker/views/add_power_line_point.dart';

// void main() => runApp(MyApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: PowerLineMap(),
    );
  }
}

class PowerLineMap extends StatefulWidget {
  @override
  State<PowerLineMap> createState() => PowerLineMapState();
}

class PowerLineMapState extends State<PowerLineMap> {
  Completer<GoogleMapController> _controller = Completer();
  Location _locationService = Location();
  // 現在位置
  LocationData? _yourLocation;

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;


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
  List<PowerLinePoint> _powerLinePointList = [];

  @override
  void initState() {
    super.initState();
    setMarkerImage();
    powerLineData.loadFromJsonFile();
    getPowerLinePointList();
    // 現在位置の取得
    _getLocation();

    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
          setState(() {
            _yourLocation = result;
          });
        });

  }

  @override
  void dispose() {
    super.dispose();

    // 監視を終了
    _locationChangedListen?.cancel();
  }


  List<PowerLinePoint> _powerLinePointListFromDocToList(
      List<DocumentSnapshot> powerLinePointSnapshot) {
    return powerLinePointSnapshot
        .map((doc) => PowerLinePoint(
            latlng: LatLng(doc['latitude'], doc['longitude']),
            names: doc['names'],
            createdAt: doc['createdAt'].toDate()))
        .toList();
  }

  Future<String> getPowerLinePointList() async {
    List<DocumentSnapshot> powerLinePointSnapshot =
        await PowerLinePointHelper.instance.selectAllPowerLinePoints();
    _powerLinePointList = _powerLinePointListFromDocToList(powerLinePointSnapshot);
    // _powerLinePointList.forEach((element) {print('${element.names}, ${element.latlng}');});

    return "complete";
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
    map = powerLineData.getPoints();
    _createMarkerAndPowerLine(map);
    // _createMarkerAndPowerLine();
    
    return "complete";
  }

  void reloadMap(){
    getPowerLinePointList();
    _createMarkerAndPowerLine(map);
  }

  // void _createMarkerAndPowerLine() {
  void _createMarkerAndPowerLine(Map<String, dynamic> map) {

    String pointName;
    LatLng latlng;
    double latitude, longitude;
    String powerLineName;
    Map<String, List<LatLng>> powerLinePoints = {};
    // print(_powerLinePointList);
    _powerLinePointList.forEach((powerLinePoint) {
      // print('${powerLinePoint.names}, ${powerLinePoint.latlng}');
      
      pointName = powerLinePoint.names;
      latlng = powerLinePoint.latlng;
      latitude = latlng.latitude;
      longitude = latlng.longitude;

      powerLineName = pointName.split('-')[0];

      if (powerLinePoints[powerLineName] == null) {
        powerLinePoints[powerLineName] = [];
      }

      powerLinePoints[powerLineName]?.add(latlng);

      // 送電電圧に応じたMarkerアイコンを取得
      var towerIcon = BitmapDescriptor.defaultMarker;
      towerIcon = getTowerIconFromVoltageSet(Set.from([154]));

      // Markerを作成し、MarkerSetに追加
      markerSet.add(Marker(
        markerId: MarkerId(pointName),
        position: latlng,
        icon: towerIcon,
        visible: true,
        // anchor: const Offset(0.5, 0.5), // バグで機能していないらしい...？ https://github.com/flutter/flutter/issues/80578
      ));

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
    });
  }


  void _onTapMarker(Marker marker) {
    setState(() {
      // _appBarTitle = marker.position.toString();
      _appBarTitle = marker.markerId.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('OnTapped: ${marker.markerId.value} ${marker.position}'),
      duration: const Duration(seconds: 1),
    ));
  }

  void _changeAppBarTitle(String title) {
    setState(() {
      _appBarTitle = title;
    });      // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('OnTapped: ${title}'),
      duration: const Duration(seconds: 1),
    ));
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
      // zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      mapType: MapType.hybrid,
      initialCameraPosition: const CameraPosition(
        zoom: 15,
        target: LatLng(35.9522505, 139.6372461),
      ),
      onTap: (LatLng latLng) {
        // _changeAppBarTitle(latLng.toString());
        _addPowerLinePoint(latLng);
      },
      fortyFiveDegreeImageryEnabled: true,
      onCameraMove: (position) => {_changedCamera(position)},
      myLocationEnabled: true,
      markers: Set.from(markerSet)
    );
  }

  GoogleMap generateGoogleMapWithPolyLine() {
    return GoogleMap(
      webGestureHandling: WebGestureHandling.greedy,
      // zoomControlsEnabled: false,
      zoomGesturesEnabled: true,
      mapType: MapType.hybrid,
      initialCameraPosition: const CameraPosition(
        zoom: 15,
        target: LatLng(35.9522505, 139.6372461),
      ),
      onTap: (LatLng latLng) {
        _addPowerLinePoint(latLng);
      },
      onCameraMove: (position) => {_changedCamera(position)},
      polylines: Set.from(powerLineList),
      myLocationEnabled: true,
    );
  }

  void _addPowerLinePoint(LatLng position){
    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => AddPowerLinePoint(title: 'test', latlng:position),
                  ),
                );
  }

  // Future<void> _setCurrentLocation(ValueNotifier<Position> position,
  //     ValueNotifier<Map<String, Marker>> markers) async {
  //   final currentPosition = await Geolocator.getCurrentPosition(
  //     // desiredAccuracy: LocationAccuracy.High,
  //   );

  //   const decimalPoint = 3;
  //   // 過去の座標と最新の座標の小数点第三位で切り捨てた値を判定
  //   if ((position.value.latitude).toStringAsFixed(decimalPoint) !=
  //           (currentPosition.latitude).toStringAsFixed(decimalPoint) &&
  //       (position.value.longitude).toStringAsFixed(decimalPoint) !=
  //           (currentPosition.longitude).toStringAsFixed(decimalPoint)) {
  //     // 現在地座標にMarkerを立てる
  //     final marker = Marker(
  //       markerId: MarkerId(currentPosition.timestamp.toString()),
  //       position: LatLng(currentPosition.latitude, currentPosition.longitude),
  //     );
  //     markers.value.clear();
  //     markers.value[currentPosition.timestamp.toString()] = marker;
  //     // 現在地座標のstateを更新する
  //     position.value = currentPosition;
  //   }
  // }

  void _getLocation() async {
    _yourLocation = await _locationService.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      
      future: loadJsonFile(),
      // future: _getPowerLinePointList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {

          return Scaffold(

            body: (displayType == 'Marker')
            ? generateGoogleMapWithMarker()
            : generateGoogleMapWithPolyLine(),
            // floatingActionButton: FloatingActionButton(
            //   onPressed: _addPowerLinePoint,
            //   tooltip: 'Increment',
            //   child: Icon(Icons.add),
            // )
          );
        } else {
          return const Scaffold(
              // appBar: AppBar(
              //   backgroundColor: Colors.purple,
              //   title: Text(_appBarTitle),
              // ),
              // drawer: const Drawer(
              //   child: Center(
              //     child: Text("Drawer")
              //   )
              // ),
              body: Center(
                  child: Text('処理中...')
              )
          );
        }
      }
    );
  }
}
