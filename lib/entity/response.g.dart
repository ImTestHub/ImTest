part of 'response.dart';

ResponseEntity _$ResponseEntityFromJson(Map<String, dynamic> json) =>
    ResponseEntity(
      code: json['code'] as int,
      data: json['data'] as dynamic,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ResponseEntityToJson(ResponseEntity instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'message': instance.message,
    };
