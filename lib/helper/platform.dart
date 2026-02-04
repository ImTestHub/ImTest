import 'package:universal_platform/universal_platform.dart';

abstract final class PlatformHelper {
  @pragma("vm:platform-const")
  static final bool isMobile =
      UniversalPlatform.isAndroid || UniversalPlatform.isIOS;

  @pragma("vm:platform-const")
  static final bool isDesktop =
      UniversalPlatform.isWindows ||
      UniversalPlatform.isMacOS ||
      UniversalPlatform.isLinux;
}
