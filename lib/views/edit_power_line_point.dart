import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:power_line_walker/models/power_line_point.dart';
import 'package:power_line_walker/repository/power_line_repository.dart';

class EditPowerLinePoint extends StatefulWidget {
  final PowerLinePoint powerLinePoint;

  const EditPowerLinePoint({super.key, required this.powerLinePoint});

  @override
  State<EditPowerLinePoint> createState() => _EditPowerLinePointState();
}

class _EditPowerLinePointState extends State<EditPowerLinePoint> {
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late List<TextEditingController> _nameControllers;
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController(text: widget.powerLinePoint.latlng.latitude.toStringAsFixed(7));
    _longitudeController = TextEditingController(text: widget.powerLinePoint.latlng.longitude.toStringAsFixed(7));
    _nameControllers = widget.powerLinePoint.names.map((name) => TextEditingController(text: name)).toList();
    if (_nameControllers.isEmpty) {
      _nameControllers.add(TextEditingController());
    }
    _selectedCategory = widget.powerLinePoint.category;
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addName() {
    setState(() {
      _nameControllers.add(TextEditingController());
    });
  }

  void _removeName(int index) {
    if (_nameControllers.length > 1) {
      setState(() {
        _nameControllers[index].dispose();
        _nameControllers.removeAt(index);
      });
    }
  }

  Future<void> _save() async {
    if (_isLoading) return;

    // Validation
    double? latitude = double.tryParse(_latitudeController.text);
    double? longitude = double.tryParse(_longitudeController.text);
    if (latitude == null || longitude == null || latitude < -180 || latitude > 180 || longitude < -180 || longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('緯度・経度は有効な数値で-180から180の範囲で入力してください。')),
      );
      return;
    }

    List<String> names = _nameControllers.map((c) => c.text.trim()).where((name) => name.isNotEmpty).toList();
    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('少なくとも1つの名前を入力してください。')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      PowerLinePoint updatedPoint = PowerLinePoint(
        latlng: LatLng(latitude, longitude),
        names: names,
        createdAt: widget.powerLinePoint.createdAt,
        category: _selectedCategory ?? 'tower',
      );
      await PowerLineRepository.instance.update(updatedPoint);
      if (mounted) {
        Navigator.of(context).pop(updatedPoint);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存しました。')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地点編集'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory ?? 'tower',
                decoration: const InputDecoration(
                  labelText: 'カテゴリ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'tower', child: Text('鉄塔')),
                  DropdownMenuItem(value: 'substation', child: Text('変電所')),
                  DropdownMenuItem(value: 'switchyard', child: Text('開閉所')),
                  DropdownMenuItem(value: 'memo', child: Text('地点メモ')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Latitude
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: '緯度',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Longitude
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: '経度',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('鉄塔名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _nameControllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameControllers[index],
                                    decoration: InputDecoration(
                                      labelText: '鉄塔名 ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeName(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _addName,
                      child: const Text('名前追加'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       // home: EditPowerLinePoint(context: context, powerLinePoint:PowerLinePoint(latlng:LatLng(35.1234567, 135.0987654), names:["東埼玉線-24"], createdAt: DateTime(2025, 01, 01, 12, 34, 56))),
//       home: EditPowerLinePoint(context: context, powerLinePoint:PowerLinePoint(latlng:LatLng(35.1234567, 135.0987654), names:["東埼玉線-24"], createdAt: DateTime(2025, 01, 01, 12, 34, 56), category:'tower')),
//     );
//   }
// }

// void main() => runApp(MyApp());
