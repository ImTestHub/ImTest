import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:im_test/helper/update/update.dart';
import 'package:im_test/http/init.dart';
import 'package:im_test/router/router.dart';
import 'package:im_test/theme/theme.dart';
import 'package:window_manager/window_manager.dart';

part 'main.g.dart';

void main() async {
  late final isDesktop;

  if (!kIsWeb) {
    isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } else {
    isDesktop = false;
  }

  await onInit(isDesktop: isDesktop);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: FlutterSmartDialog.init(),
      title: "在线客服聊天系统(客服侧)",
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.theme().useSystemChineseFont(Brightness.light),
      darkTheme: AppTheme.darkTheme().useSystemChineseFont(Brightness.dark),
    );
  }
}
