part of 'main.dart';

Future<void> onInit({required bool isDesktop}) async {
  WidgetsFlutterBinding.ensureInitialized();

  Request();

  if (isDesktop) {
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
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
