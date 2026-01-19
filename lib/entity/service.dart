import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

class ServiceEntity {
  @JsonKey(name: 'create_tm')
  final int create_tm;

  @JsonKey(name: 'service_id')
  final String service_id;

  @JsonKey(name: 'service_robot')
  final String service_robot;


  @JsonKey(name: 'staff_id')
  final String staff_id;

  @JsonKey(name: 'staff_join_tm')
  final int staff_join_tm;

  @JsonKey(name: 'stage')
  final String stage;

  ServiceEntity({
    required this.create_tm,
    required this.service_id,
    required this.service_robot,
    required this.staff_id,
    required this.staff_join_tm,
    required this.stage,
  });

  // 自动生成的反序列化方法
  factory ServiceEntity.fromJson(Map<String, dynamic> json) =>
      _$ServiceEntityFromJson(json);

  // 自动生成的序列化方法
  Map<String, dynamic> toJson() => _$ServiceEntityToJson(this);
}
