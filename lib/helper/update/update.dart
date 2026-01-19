import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:im_test/build_config.dart';
import 'package:im_test/http/init.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ua_type.dart';

abstract class UpdateHelper {
  // 检查更新
  static Future<void> checkUpdate() async {
    if (kDebugMode) return;

    try {
      final res = await Request().get(
        'https://api.github.com/repos/TroilOryan/ImTest/releases',
        options: Options(headers: {'user-agent': UaType.mob.ua}),
      );

      if (res.data is Map || res.data.isEmpty) {
        SmartDialog.showToast("检查更新失败，接口未返回数据，请检查网络");
        return;
      }
      final data = res.data[0];

      final int latest =
          DateTime.parse(data['created_at']).millisecondsSinceEpoch ~/ 1000;
      if (BuildConfig.buildTime >= latest) {
      } else {
        SmartDialog.show(
          animationType: SmartAnimationType.centerFade_otherSlide,
          builder: (context) {
            final ThemeData theme = Theme.of(context);
            Widget downloadBtn(String text, {String? ext}) => TextButton(
              onPressed: () => onDownload(data, ext: ext),
              child: Text(text),
            );
            return AlertDialog(
              title: const Text('🎉 发现新版本 '),
              content: SizedBox(
                height: 280,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['tag_name']}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      Text('${data['body'] ?? "暂无更新内容"}'),
                    ],
                  ),
                ),
              ),
              actions: [
                if (Platform.isWindows) ...[
                  downloadBtn('zip', ext: 'zip'),
                  downloadBtn('exe', ext: 'exe'),
                ] else if (Platform.isLinux) ...[
                  downloadBtn('rpm', ext: 'rpm'),
                  downloadBtn('deb', ext: 'deb'),
                  downloadBtn('targz', ext: 'tar.gz'),
                ] else
                  downloadBtn('Github'),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('failed to check update: $e');
    }
  }

  // 下载适用于当前系统的安装包
  static Future<void> onDownload(Map data, {String? ext}) async {
    try {
      void download(String plat) {
        if (data['assets'].isNotEmpty) {
          for (Map<String, dynamic> i in data['assets']) {
            final String name = i['name'];
            if (name.contains(plat) &&
                ((ext == null || ext.isEmpty) ? true : name.endsWith(ext))) {
              launchURL(i['browser_download_url']);
              return;
            }
          }
          throw UnsupportedError('platform not found: $plat');
        }
      }

      if (Platform.isAndroid) {
        // 获取设备信息
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        // [arm64-v8a]
        download(androidInfo.supportedAbis.first);
      } else {
        download(Platform.operatingSystem);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('download error: $e');
      // launchURL('${Constants.sourceCodeUrl}/releases/latest');
    }
  }
}

Future<void> launchURL(
  String url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  try {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: mode)) {
      SmartDialog.showToast('Could not launch $url');
    }
  } catch (e) {
    SmartDialog.showToast(e.toString());
  }
}
