import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:brotli/brotli.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class Request {
  static const _gzipDecoder = GZipDecoder();
  static const _brotilDecoder = BrotliDecoder();

  static final Request _instance = Request._internal();

  static String baseUrl = "http://10.138.20.96:9890";

  static late Dio dio;

  factory Request() => _instance;

  void setBaseUrl(String value) {
    baseUrl = value;

    dio.options.baseUrl = baseUrl;
  }

  /*
   * config it and create
   */
  Request._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseDecoder: _responseDecoder,
      // Http2Adapter没有自动解压
      persistentConnection: true,
    );

    final http11Adapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()
        ..idleTimeout = const Duration(seconds: 15)
        ..autoUncompress = false, // Http2Adapter没有自动解压, 统一行为
    );

    dio = Dio(options)..httpClientAdapter = http11Adapter;

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    dio
      ..transformer = BackgroundTransformer()
      ..options.validateStatus = (int? status) {
        return status != null && status >= 200 && status < 300;
      };
  }

  Future<Response> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return Response(
        data: {'message': e}, // 将自定义 Map 数据赋值给 Response 的 data 属性
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  Future<Response> post<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      return Response(
        data: {},
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  /*
   * 下载文件
   */
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.download(
        urlPath,
        savePath,
        cancelToken: cancelToken,
        // onReceiveProgress: (int count, int total) {
        // 进度
        // if (kDebugMode) debugPrint("$count $total");
        // },
      );
      // if (kDebugMode) debugPrint('downloadFile success: ${response.data}');
    } on DioException catch (e) {
      // if (kDebugMode) debugPrint('downloadFile error: $e');
      return Response(
        statusCode: e.response?.statusCode ?? -1,
        requestOptions: e.requestOptions,
      );
    }
  }

  static List<int> responseBytesDecoder(
    List<int> responseBytes,
    Map<String, List<String>> headers,
  ) => switch (headers['content-encoding']?.firstOrNull) {
    'gzip' => _gzipDecoder.decodeBytes(responseBytes),
    'br' => _brotilDecoder.convert(responseBytes),
    _ => responseBytes,
  };

  static String _responseDecoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    return utf8.decode(
      responseBytesDecoder(responseBytes, responseBody.headers),
      allowMalformed: true,
    );
  }
}
