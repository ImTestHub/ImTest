import 'dart:convert';

import 'package:im_test/entity/service.dart';
import 'package:im_test/http/init.dart';

class API {
  static Future<List<ServiceEntity>> serviceList(String account) async {
    final res = await Request().post<String>(
      "/service-list",
      data: {"account": account},
    );

    final List<dynamic>? dataList = res.data != null
        ? jsonDecode(res.data)["data"]
        : [];

    if (dataList == null) {
      return [];
    }

    return dataList
        .map((e) => ServiceEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future refreshToken(String token) async {
    final res = await Request().post<String>(
      "/refresh-token",
      data: {"token": token},
    );

    final String newToken = res.data != null
        ? jsonDecode(res.data)["data"]["token"]
        : [];

    return newToken;
  }
}
