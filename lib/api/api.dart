import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:im_test/entity/service.dart';
import 'package:im_test/entity/source.dart';
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

  static Future<SourceEntity> upload(FormData data) async {
    final res = await Request().post<String>("/upload", data: data);

    return SourceEntity.fromJson(jsonDecode(res.data)["data"]);
  }

  static Future<Uint8List?> source(String source_id) async {
    late final d;

    final res = await Request().get<String>(
      "/source",
      queryParameters: {"source_id": source_id},
      options: Options(
        responseDecoder:
            (
              List<int> responseBytes,
              RequestOptions options,
              ResponseBody responseBody,
            ) {
              d = responseBytes;
              return responseBytes.toString();
            },
      ),
    );

    return Uint8List.fromList(d);
  }
}
