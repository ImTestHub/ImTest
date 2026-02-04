part of 'main.dart';

Future<void> onInit() async {
  WidgetsFlutterBinding.ensureInitialized();

  Request();

  await Hive.initFlutter();

  await Hive.openBox("cache");

  if (PlatformHelper.isDesktop) {
    await windowManager.ensureInitialized();

    UpdateHelper.checkUpdate();

    WindowOptions windowOptions = WindowOptions(
      size: Size(400, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.center();

      Future.delayed(const Duration(milliseconds: 500)).then((_) async {
        await windowManager.show();
        await windowManager.focus();
      });
    });

    trayManager.setIcon(
      Platform.isWindows
          ? 'assets/images/app_icon.ico'
          : 'assets/images/app_icon.png',
    );

    trayManager.setToolTip("在线客服聊天系统(客服侧)");

    Menu menu = Menu(
      items: [
        MenuItem(key: 'show', label: '显示'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: '退出'),
      ],
    );

    trayManager.setContextMenu(menu);
  }
}
