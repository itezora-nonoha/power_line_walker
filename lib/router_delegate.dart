
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_line_walker/id_provider.dart';
import 'package:power_line_walker/main.dart';
import 'package:power_line_walker/views/data_list.dart';

// 今回の実装では AppRouterDelegate がリビルドされる可能性があるためグローバルに宣言
final _navigatorKey = GlobalKey<NavigatorState>();

class AppRouterDelegate extends RouterDelegate<Empty>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Empty> {
  AppRouterDelegate(this.ref);
  final WidgetRef ref; // 渡される

  @override
  final GlobalKey<NavigatorState>? navigatorKey = _navigatorKey;

  String get id => ref.watch(idProvider);
  StateController<String> get provider => ref.read(idProvider.notifier);
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        const MaterialPage(child: MapScreen()),
        if (id == 'fuga') const MaterialPage(child: FugaScreen()),
        if (id == 'MyDataListPage') const MaterialPage(child: MyDataListPage())
      ],
      onPopPage: (route, result) {
        provider.state = '';
        return route.didPop(result);
      },
    );
  }

  @override
  Future<void> setNewRoutePath(Empty configuration) async {}
}

class Empty {}
