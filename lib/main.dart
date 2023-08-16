import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:power_line_walker/firebase_options.dart';
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
  final String _appBarTitle = "Power Line Walker";

  void _addPowerLinePoint(){

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
          child: Text("Drawer")
        )
      ),
      body: PowerLineMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPowerLinePoint,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      )
    );
  }
}
