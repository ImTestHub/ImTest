import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:im_test/helper/platform.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

final baseManager = BaseManager();

enum PlatformType { windows, android, fuchsia, iOS, linux, macOS, web }

class BaseManager {
  final Signal<PlatformType> _platform;

  final Signal<bool> _isMaximized;

  final Signal<String> _env;

  final Signal<double> _keyboardHeight;

  final Signal<bool> _keyboardVisible;

  Signal<PlatformType> get platform => _platform;

  Signal<bool> get isMaximized => _isMaximized;

  Signal<String> get env => _env;

  Signal<double> get keyboardHeight => _keyboardHeight;

  Signal<bool> get keyboardVisible => _keyboardVisible;

  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  BaseManager()
    : _platform = signal(PlatformType.windows),
      _isMaximized = signal(false),
      _env = signal(""),
      _keyboardHeight = signal(0.0),
      _keyboardVisible = signal(false) {
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

    _keyboardHeightPlugin.onKeyboardHeightChanged((double height) {
      if (height != 0) {
        _keyboardHeight.value = height;
        _keyboardVisible.value = true;
      } else {
        _keyboardVisible.value = false;
      }
    });

    if (PlatformHelper.isDesktop) {
      windowManager.isMaximized().then((res) {
        _isMaximized.value = res;
      });
    }
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
