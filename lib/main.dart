import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:power_line_walker/firebase_options.dart';
import 'package:power_line_walker/views/add_power_line_point.dart';
import 'package:power_line_walker/views/data_list.dart';
import 'package:power_line_walker/views/power_line_map.dart';

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
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  MyDataListPage dataListPage = const MyDataListPage(title:'test');

  final String _appBarTitle = "Power Line Walker";

  void _addPowerLinePoint(){
    Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => AddPowerLinePoint(title: 'test'),
                  ),
                );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(_appBarTitle),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            // const DrawerHeader(
            //   child: Text('Drawer Header'),
            //      decoration: BoxDecoration(
            //      color: Colors.blue,
            //   ),
            // ),
            ListTile(
              title: Text('データ一覧'),
              onTap: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => dataListPage,
                  ),
                ),
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
          ],
        )
      ),
      body: PowerLineMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPowerLinePoint,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      )
    );
  }
}
