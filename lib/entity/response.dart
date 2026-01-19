import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

class ResponseEntity {
  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'data')
  final dynamic data;

  @JsonKey(name: 'message')
  final String message;

  ResponseEntity({
    required this.code,
    required this.data,
    required this.message,
  });

  // 自动生成的反序列化方法
  factory ResponseEntity.fromJson(Map<String, dynamic> json) =>
      _$ResponseEntityFromJson(json);

  // 自动生成的序列化方法
  Map<String, dynamic> toJson() => _$ResponseEntityToJson(this);
}
