part of 'service.dart';

ServiceEntity _$ServiceEntityFromJson(Map<String, dynamic> json) =>
    ServiceEntity(
      create_tm: json['create_tm'] as int,
      service_id: json['service_id'] as String,
      service_robot: json['service_robot'] as String,
      staff_id: json['staff_id'] as String,
      staff_join_tm: json['staff_join_tm'] as int,
      stage: json['stage'] as String,
    );

Map<String, dynamic> _$ServiceEntityToJson(ServiceEntity instance) =>
    <String, dynamic>{
      'create_tm': instance.create_tm,
      'service_id': instance.service_id,
      'service_robot': instance.service_robot,
      'staff_id': instance.staff_id,
      'staff_join_tm': instance.staff_join_tm,
      'stage': instance.stage,
    };
