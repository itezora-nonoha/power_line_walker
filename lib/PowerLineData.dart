import 'dart:convert';
import 'dart:io';

// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PowerLineData {
  PowerLineData(){
    loadFromJsonFile();
    print("test");
  }

  Map<String, dynamic> map = {};
  Map<String, List<LatLng>> points = {};
  String name = "test";

  Future<String> loadFromJsonFile() async {
  // Future<Map<String, dynamic>?> loadJsonFile() async {
    String str;
    str = await rootBundle.loadString("assets/higashisaitama.json");
    map = json.decode(str);
    return "complete";
  }

// Future<void>get() async {
// //     const lat = '35.65138';
// //     const lon = '139.63670';
// //     const key = 'aa50ce0598c22de20f75cf3ea31ac312';

//     const domain = 'https://script.googleapis.com';
//     const pass = '/v1/scripts/AKfycbyBc4K0t2n_6itPUyZASY4tWiX359YRuSLb-bGS4Gqkvtb-nSfx7jOm40Y5uoBn_t1nBg:run';
//     const payload = {
//       "function": 'getActiveSheetName',
//       // parameters": ['Hello, world!']
//     };


// //     const query = '?lat=$lat&lon=$lon&exclude=daily&lang=ja&appid=$key';
//     // var url = Uri.parse(domain + pass + query);
//     var url = Uri.parse(domain + pass);
// //     debugPrint('url: $url');
//     final response = await http.post(url, body: {
//       'function': 'getActiveSheetName',
//     });
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

    // HttpClient client = new HttpClient();
    // HttpClientRequest request = await client.postUrl(url,);
    // request.followRedirects = true; //リダイレクトを許可する
    // request.headers.contentType = ContentType("application", "json", charset: "utf-8");
    // // request.write(body);

    // final HttpClientResponse response = await request.close();
    // client.close();
    // final String responseBody = await response.transform(utf8.decoder).join();
    // debugPrint('$responseBody');
    // final dynamic responseJson = jsonDecode(responseBody);
    // debugPrint('$responseJson');
    // var response = await http.get(url);

//     if (response.statusCode == 200) {
//       var body = response.body;
//       var decodeData = jsonDecode(body);
//       var json = decodeData['current'];
//       var model = WeatherModel.fromJson(json);

//       return model;
//     }
//     return null;
// }

  Map<String, dynamic> getPoints(){
    return map;
  }

}


void main(){
  PowerLineData powerLineData = PowerLineData();
  powerLineData.getPoints();
  powerLineData.loadFromJsonFile().then((t) => {print(powerLineData.getPoints())});
}
