import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:power_line_walker/firebase_options.dart';

import 'package:power_line_walker/views/add_power_line_point.dart';
import 'package:power_line_walker/views/power_line_repository.dart';

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
  const PowerLineMap({Key? key}) : super(key: key);
  // PowerLineMap(key);
  // @override
  State<PowerLineMap> createState() => PowerLineMapState();
}

class PowerLineMapState extends State<PowerLineMap> {
  Completer<GoogleMapController> _controller = Completer();
  Location _locationService = Location();
  // 現在位置
  LocationData? _yourLocation;

  // 現在位置の監視状況
  StreamSubscription? _locationChangedListen;

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
  List<Polyline> powerLineListSub = []; // Markerと同時に表示するようの補助用Polyline
  // List<PowerLinePoint> _powerLinePointList = [];
  late Map<String, double> _powerLineVoltageMap = {};
  late GoogleMap googleMapWithMarker;
  late GoogleMap googleMapWithPolyLine;

  @override
  void initState() {
    super.initState();
    setMarkerImage();
    // getPowerLinePointList();
    // getPowerLineList();
    // 現在位置の取得
    _getLocation();
    PowerLineRepository.instance.fullReload();
  
    // 現在位置の変化を監視
    _locationChangedListen =
        _locationService.onLocationChanged.listen((LocationData result) async {
          setState(() {
            _yourLocation = result;
          });
        });
    print('---------- initState is Completed ----------');
  }

  @override
  void dispose() {
    super.dispose();

    // 監視を終了
    _locationChangedListen?.cancel();
  }

  void refleshMap(){

    PowerLineRepository.instance.fullReload().then((value) {
      _createMarkerAndPowerLine();
      generateGoogleMap().then((value) {
        build(context);
        setState(() {});
      });
    });
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


  Future<String> _createMarkerAndPowerLine() async {
    markerSet = {};
    powerLineList = [];
    powerLineListSub = [];

    String pointLabel;
    LatLng latlng;
    String powerLineName;
    Map<String, dynamic> powerLineLatLngMap = {};

    
    // 電圧マップの構築
    PowerLineRepository.instance.getPowerLineList().forEach((powerLine) {
      _powerLineVoltageMap[powerLine.name] = powerLine.transmissionVoltage;
    });

    PowerLineRepository.instance.getPowerLinePointList().forEach((powerLinePoint) {
      
      pointLabel = powerLinePoint.names[0];
      latlng = powerLinePoint.latlng;

      List<double> voltageSet = [];
      powerLinePoint.names.forEach((powerLineNames) {
        powerLineName = powerLineNames.split('-')[0];
        
        if (_powerLineVoltageMap[powerLineName] != null){
        voltageSet.add(_powerLineVoltageMap[powerLineName]!);
        }
        if (powerLineLatLngMap[powerLineName] == null) {
          Map<double, LatLng> map = {};
          powerLineLatLngMap[powerLineName] = map;
        }
        var num = double.parse(powerLineNames.split('-')[1]);
        powerLineLatLngMap[powerLineName][num] = latlng;
      });

      // 送電電圧に応じたMarkerアイコンを取得
      var towerIcon = BitmapDescriptor.defaultMarker;
      towerIcon = getTowerIconFromVoltageSet(Set.from(voltageSet));

      // Markerを作成し、MarkerSetに追加
      markerSet.add(Marker(
        markerId: MarkerId(pointLabel),
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
      for (var name in powerLineLatLngMap.keys) {
        List<LatLng> latLngList = [];
        // 鉄塔番号でソート
        Map<double, dynamic> map = SplayTreeMap.from(powerLineLatLngMap[name], (a, b) => a.compareTo(b)); 
        map.forEach((k, v) => latLngList.add(v));

        // リストの作成
        // powerLineLatLngMap[name].forEach((k, v) => latLngList.add(v));

        // 送電電圧の取得
        // var entry = map['powerLines'].where((e) => e['name'] == name);
        // transmissionVoltage = entry.first['transmissionVoltage'];
        transmissionVoltage = _powerLineVoltageMap[name] as int;
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
        
        Polyline polyline = Polyline(
          polylineId: PolylineId(name),
          points: latLngList,
          color: powerLineColor,
          width: 5,
        );
        powerLineList.add(polyline);

        Polyline polylineSub = Polyline(
          polylineId: PolylineId(name),
          points: latLngList,
          color: powerLineColor,
          width: 2,
          // patterns: [PatternItem.dash(3)]
        );
        powerLineListSub.add(polylineSub);
      }
    });
    return "complete";
  }

  Future<String> generateGoogleMap() async {
    if (powerLineList.isEmpty){
      _createMarkerAndPowerLine();
    }
    googleMapWithMarker = generateGoogleMapWithMarker();
    googleMapWithPolyLine = generateGoogleMapWithPolyLine();
    return "complete";
  }

  void _onTapMarker(Marker marker) {
    setState(() {
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
      if (position.zoom > 13) {
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
      onLongPress: (LatLng latLng) {
        _addPowerLinePoint(latLng);
      },
      fortyFiveDegreeImageryEnabled: true,
      onCameraMove: (position) => {_changedCamera(position)},
      myLocationEnabled: true,
      markers: Set.from(markerSet),
      polylines: Set.from(powerLineListSub),
      onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      myLocationButtonEnabled: true,
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
      onLongPress: (LatLng latLng) {
        _addPowerLinePoint(latLng);
      },
      onCameraMove: (position) => {_changedCamera(position)},
      polylines: Set.from(powerLineList),
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      myLocationButtonEnabled: true,
    );
  }

  void _addPowerLinePoint(LatLng position){
    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => AddPowerLinePoint(title: 'test', latlng:position),
                  ),
                );
  }

  void _getLocation() async {
    _yourLocation = await _locationService.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      
      future: generateGoogleMap(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {

          return Scaffold(

            body: (displayType == 'Marker')
            ? googleMapWithMarker
            : googleMapWithPolyLine,
            // floatingActionButton: FloatingActionButton(
            //   onPressed: _addPowerLinePoint,
            //   tooltip: 'Increment',
            //   child: Icon(Icons.add),
            // )
          );
        } else {
          return const Scaffold(
              body: Center(
                  // child: Text('処理中...')
                  child: CircularProgressIndicator()
              )
          );
        }
      }
    );
  }
}
