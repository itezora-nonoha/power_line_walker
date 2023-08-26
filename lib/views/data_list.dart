import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/views/power_line_repository.dart';

class MyDataListPage extends StatefulWidget {
  const MyDataListPage({super.key, required this.title});

  final String title;

  @override
  State<MyDataListPage> createState() => _MyDataListPageState();
}

class _MyDataListPageState extends State<MyDataListPage> {
  final String _userId = 'test';
  final String _pointName = 'test';
  final TextEditingController _controllerLatitude = TextEditingController();
  final TextEditingController _controllerLongitude = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  List<PowerLinePoint> _powerLinePointList = [];

  @override
  void initState() {
    super.initState();
    _getPowerLinePointList();
  }

  @override
  void dispose() {
    _controllerLatitude.dispose();
    _controllerLongitude.dispose();
    super.dispose();
  }

  List<PowerLinePoint> _powerLinePointListFromDocToList(
      List<DocumentSnapshot> powerLinePointSnapshot) {
    return powerLinePointSnapshot
        .map((doc) => PowerLinePoint(
            latlng: LatLng(doc['latitude'], doc['longitude']),
            names: List.from(doc['names']),
            createdAt: doc['createdAt'].toDate()))
        .toList();
  }

  void _getPowerLinePointList() async {
    _powerLinePointList = PowerLineRepository.instance.getPowerLinePointList();
    
    _powerLinePointList.forEach((element) {print('${element.names}, ${element.latlng}');});
    setState(() {});
  }

  void _addPowerLinePoint(LatLng latlng, List<String> names) async {
    final PowerLinePoint powerLinePoint = PowerLinePoint(
        latlng: latlng, names:names, createdAt: DateTime.now());
    await PowerLineRepository.instance.insert(powerLinePoint);
    _powerLinePointList.add(powerLinePoint);
    setState(() {});
  }

  void _deletePowerLinePoint(String pointName, int index) async {
    await PowerLineRepository.instance.delete(pointName);
    _powerLinePointList.removeAt(index);
    setState(() {});
  }

  void _getPowerLinePoint(String names) async {
    PowerLinePoint? powerLinePoint =
        await PowerLineRepository.instance.selectPowerLinePoint(names);
    if (powerLinePoint != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${powerLinePoint.names} ${powerLinePoint.latlng.latitude} : ${powerLinePoint.latlng.longitude}'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                child: _powerLinePointList.isEmpty
                    ? const Center(child: Text('NO DATA'))
                    : ListView.builder(
                        itemCount: _powerLinePointList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final powerLinePoint = _powerLinePointList[index];
                          return Card(
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        powerLinePoint.names[0],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Text(
                                    //     powerLinePoint.latlng.latitude.toString(),
                                    //     style: const TextStyle(fontSize: 16),
                                    //   ),
                                    // ),
                                    // Expanded(
                                    //   child: Text(
                                    //     powerLinePoint.latlng.longitude.toString(),
                                    //     style: const TextStyle(fontSize: 16),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _getPowerLinePoint(powerLinePoint.names[0]);
                                          },
                                          child: const Icon(
                                            Icons.book,
                                            size: 15,
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                      height: 25,
                                    ),
                                    SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            _deletePowerLinePoint(powerLinePoint.names[0], index);
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            size: 15,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _controllerLatitude,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: 'latitude'),
                )),
                Expanded(
                    child: TextField(
                  controller: _controllerLongitude,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: 'longitude'),
                )),
                Expanded(
                    child: TextField(
                  controller: _controllerName,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: 'name'),
                  onSubmitted: (String value) {
                    double latitude = double.parse(_controllerLatitude.text);
                    double longitude = double.parse(_controllerLongitude.text);
                    LatLng latlng = LatLng(latitude, longitude);
                    print(latlng);  
                    _addPowerLinePoint(latlng, _controllerName.text.split(','));_controllerLatitude.clear();
                    _controllerLongitude.clear();
                    _controllerName.clear();
                  },
                )),
                ElevatedButton(
                    onPressed: () {
                    double latitude = double.parse(_controllerLatitude.text);
                    double longitude = double.parse(_controllerLongitude.text);
                    LatLng latlng = LatLng(latitude, longitude);
                    print(latlng);  
                    _addPowerLinePoint(latlng, _controllerName.text.split(','));
                    _controllerLatitude.clear();
                    _controllerLongitude.clear();
                    _controllerName.clear();
                  },
                    child: const Icon(Icons.add)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
