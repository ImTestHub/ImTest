import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:im_test/helper/platform.dart';
import 'package:im_test/helper/update/update.dart';
import 'package:im_test/http/init.dart';
import 'package:im_test/router/router.dart';
import 'package:im_test/theme/theme.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'main.g.dart';

void main() async {
  await onInit();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with TrayListener {
  @override
  void initState() {
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    // do something, for example pop up the menu
  }

  @override
  void onTrayIconRightMouseDown() {
    // do something
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {
    // do something
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show') {
      // do something
      windowManager.show();
    } else if (menuItem.key == 'exit') {
      // do something
      windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: FlutterSmartDialog.init(),
      title: "在线客服聊天系统(客服侧)",
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.theme(),
      darkTheme: AppTheme.darkTheme(),
    );
  }
}
