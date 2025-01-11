import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:power_line_walker/firebase_options.dart';
import 'package:power_line_walker/id_provider.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/router_delegate.dart';
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
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      // home: MapSample(),
      home: Router(
        routerDelegate: AppRouterDelegate(ref),
      ),
    );
  }
}
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(),
//     );
//   }
// }

// class MapSample extends StatelessWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapSample();
  }
}

// class MapSampleState extends State<MapSample> {
class MapSample extends ConsumerWidget {

  final mapViewKey = GlobalKey<PowerLineMapState>();
  // final dataListViewKey = GlobalKey<MyDataListPageState>();

  late PowerLineMap powerLineMapView = PowerLineMap(key: mapViewKey);
  // late MyDataListPage dataListPage = MyDataListPage(key: dataListViewKey);
  late PowerLinePoint point;
  final String _appBarTitle = "Power Line Walker";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlue,
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
            onPressed: () => ref.read(idProvider.notifier).state = 'MyDataListPage',
            // onPressed: () { 
            //   Navigator.of(context).push(MaterialPageRoute<PowerLinePoint>(
            //     builder: (context) => MyDataListPage())).then((powerLinePoint) {
            //       print(powerLinePoint);
            //       if (powerLinePoint != null){
            //         // ScaffoldMessenger.of(context).showSnackBar(
            //         //   SnackBar(content: Text(powerLinePoint.toString()))
            //         // );
            //         mapViewKey.currentState?.gotoLocation(powerLinePoint.latlng.latitude, powerLinePoint.latlng.longitude);
            //       }
            //     });
              // _dataListPage(context).then((value) {
              //   print(value);
              //   if (value != null){
              //     point = value;
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text(point.toString())));

              //     }
              //   });
              // }
            // onPressed: () {point = _dataListPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'マーカーの再描画',
            onPressed: () {
              mapViewKey.currentState?.refleshMap();
              // ScaffoldMessenger.of(context).showSnackBar(
                  // const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'データの再読み込みとマーカーの再描画',
            onPressed: () {
              mapViewKey.currentState?.reloadAndRefleshMap();
              // ScaffoldMessenger.of(context).showSnackBar(
                  // const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            tooltip: '表示レイヤー切り替え',
            onPressed: () {mapViewKey.currentState?.changeMapView();}
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            tooltip: '遷移テスト',
            onPressed: () => ref.read(idProvider.notifier).state = 'fuga',
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

class FugaScreen extends StatelessWidget {
  const FugaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遷移先テスト'),
        backgroundColor: Colors.blue, // わかりやすいように色付け
      ),
    );
  }
}
