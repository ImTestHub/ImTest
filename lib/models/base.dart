import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

final baseManager = BaseManager();

enum PlatformType { windows, android, fuchsia, iOS, linux, macOS, web }

class BaseManager {
  final Signal<PlatformType> _platform;

  final Signal<bool> _isMaximized;

  final Signal<String> _env;

  Signal<PlatformType> get platform => _platform;

  Signal<bool> get isMaximized => _isMaximized;

  Signal<String> get env => _env;

  BaseManager()
    : _platform = signal(PlatformType.windows),
      _isMaximized = signal(false),
      _env = signal("") {
    if (kIsWeb) {
      _platform.value = PlatformType.web;
    } else if (Platform.isWindows) {
      _platform.value = PlatformType.windows;
    } else if (Platform.isAndroid) {
      _platform.value = PlatformType.android;
    } else if (Platform.isFuchsia) {
      _platform.value = PlatformType.fuchsia;
    } else if (Platform.isIOS) {
      _platform.value = PlatformType.iOS;
    } else if (Platform.isLinux) {
      _platform.value = PlatformType.linux;
    } else if (Platform.isMacOS) {
      _platform.value = PlatformType.macOS;
    }

    windowManager.isMaximized().then((res) {
      _isMaximized.value = res;
    });
  }

  void setPlatform(PlatformType value) {
    _platform.value = value;
  }

  void setIsMaximized(bool value) {
    _isMaximized.value = value;
  }

  void setEnv(String value) {
    _env.value = value;
  }
}
