import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
        const ImageConfiguration(size: Size(32, 32)), 'assets/tower.png');
    setState(() {
    });
  }

  Set<Marker> markers = {};
  final List<LatLng> _markerLocations = [
    const LatLng(35.9522505, 139.6372461),
    const LatLng(35.9514831, 139.6395112),
  ];

  Set<Marker> _createMarker() {
    _markerLocations.asMap().forEach((i, markerLocation) {
      markers.add(
        Marker(
          markerId: MarkerId('myMarker{$i}'),
          position: markerLocation,
          icon: pinLocationIcon,
        ),
      );
    });

    // マーカークリック時のイベントを設定
    markers = markers
        .map((e) => e.copyWith(onTapParam: () => _onTapMarker(e)))
        .toSet();

    return markers;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: Text(_appBarTitle),
        ),
        drawer: const Drawer(
            child: Center(
          child: Text("Drawer"),
        )),
        body: GoogleMap(
          zoomGesturesEnabled: true,
          mapType: MapType.hybrid,
          initialCameraPosition: const CameraPosition(
            zoom: 15,
            target: LatLng(35.9522505, 139.6372461),
          ),
          markers: Set.from(_createMarker()),
          onTap: (LatLng latLng) {
            _changeAppBarTitle(latLng.toString());
          },
          onCameraMove: (position) => {_changedCamera(position)},
        ));
  }
}
