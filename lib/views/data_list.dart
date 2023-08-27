import 'package:flutter/material.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/views/power_line_repository.dart';

class MyDataListPage extends StatefulWidget {
  const MyDataListPage({Key? key}) : super(key: key,);

  @override
  State<MyDataListPage> createState() => MyDataListPageState();
}

class MyDataListPageState extends State<MyDataListPage> {

  // final TextEditingController _controllerLatitude = TextEditingController();
  // final TextEditingController _controllerLongitude = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  List<PowerLinePoint> _pointList = [];
  List<PowerLinePoint> _pointListFiltered = [];
  List<PowerLinePoint> _pointListDisplaying = [];

  @override
  void initState() {
    super.initState();
    _pointList = PowerLineRepository.instance.getPowerLinePointList();
    _pointListFiltered = _pointList;
  }

  @override
  void dispose() {
    // _controllerLatitude.dispose();
    // _controllerLongitude.dispose();
    super.dispose();
  }

  void _deletePowerLinePoint(String pointKey, int index) async {
    await PowerLineRepository.instance.delete(pointKey);
    _pointList.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _pointListDisplaying = _pointListFiltered;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('地点情報一覧'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SizedBox(
                child: _pointListDisplaying.isEmpty
                    ? const Center(child: Text('NO DATA'))
                    : ListView.builder(
                        itemCount: _pointListDisplaying.length,
                        itemBuilder: (BuildContext context, int index) {
                          final powerLinePoint = _pointListDisplaying[index];
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
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Text(
                                    //     // powerLinePoint.latlng.latitude.toString(),
                                    //     powerLinePoint.names.toString(),
                                    //     style: const TextStyle(fontSize: 12),
                                    //     textAlign: TextAlign.left,
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
                                      child: Tooltip(
                                        message:'地点の詳細',
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(powerLinePoint.toString()),
                                              duration: const Duration(seconds: 1),
                                            ));
                                          },
                                          child: const Icon(Icons.book, size: 15)
                                        )
                                      ),
                                    ),
                                    const SizedBox(width: 5, height: 25),
                                    SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Tooltip(
                                        message:'地点へ移動',
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(powerLinePoint);
                                          },
                                          child: const Icon(Icons.location_on, size: 15)
                                        )
                                      ),
                                    ),
                                    const SizedBox(width: 5, height: 25),
                                    SizedBox(
                                      width: 50,
                                      height: 25,
                                      child: Tooltip(
                                        message:'地点情報の削除',
                                        child: ElevatedButton(
                                            onPressed: () {
                                              _deletePowerLinePoint(powerLinePoint.generateUniqueKey(), index);
                                            },
                                            child: const Icon(Icons.delete, size: 15)
                                          )
                                      ),
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
                  controller: _controllerName,
                  autofocus: false,
                  decoration: const InputDecoration(labelText: '検索テキスト'),
                  onSubmitted: (String value) {
                    _onPressedSearchButton();
                  },
                )),
                ElevatedButton(
                    onPressed: _onPressedSearchButton,
                    child: const Icon(Icons.search)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPressedSearchButton() {
    _filteringPointList(_controllerName.value.text);
    setState(() {});
    // _controllerName.clear();
  }

  void _filteringPointList(String searchWord) {
    print('filtering $searchWord');
    _pointListFiltered = _pointList.where((point) {
      var nameList = point.names;
      return nameList.any((name) => name.contains(searchWord));
    }).toList();
  }
}
