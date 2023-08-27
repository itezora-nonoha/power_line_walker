import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:power_line_walker/firebase_options.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/views/add_power_line_point.dart';
import 'package:power_line_walker/views/data_list.dart';
import 'package:power_line_walker/views/power_line_map.dart';
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
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

// class MapSample extends StatelessWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

// class MapSampleState extends State<MapSample> {
class MapSample extends StatelessWidget {
  final mapViewKey = GlobalKey<PowerLineMapState>();
  // final dataListViewKey = GlobalKey<MyDataListPageState>();

  late PowerLineMap powerLineMapView = PowerLineMap(key: mapViewKey);
  // late MyDataListPage dataListPage = MyDataListPage(key: dataListViewKey);
  late PowerLinePoint point;
  final String _appBarTitle = "Power Line Walker";

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(_appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: '現在地周辺へ移動',
            onPressed: () {
              mapViewKey.currentState?.gotoCurrentLocation();
              // ScaffoldMessenger.of(context).showSnackBar(
                  // const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: '地点情報一覧',
            onPressed: () { 
              Navigator.of(context).push(MaterialPageRoute<PowerLinePoint>(
                builder: (context) => MyDataListPage())).then((powerLinePoint) {
                  print(powerLinePoint);
                  if (powerLinePoint != null){
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text(powerLinePoint.toString()))
                    // );
                    mapViewKey.currentState?.gotoLocation(powerLinePoint.latlng.latitude, powerLinePoint.latlng.longitude);
                  }
                });
              // _dataListPage(context).then((value) {
              //   print(value);
              //   if (value != null){
              //     point = value;
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(point.toString())));

              //     }
              //   });
              }
            // onPressed: () {point = _dataListPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'データの再読み込みと再描画',
            onPressed: () {
              mapViewKey.currentState?.refleshMap();
              // ScaffoldMessenger.of(context).showSnackBar(
                  // const SnackBar(content: Text('This is a snackbar')));
            },
          )
        ]
      ),
      body: powerLineMapView,
    ));
  }

  Future<PowerLinePoint?> _dataListPage(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute<PowerLinePoint>(
          builder: (context) => MyDataListPage()
      )
    ) as PowerLinePoint;
  }
  
}

