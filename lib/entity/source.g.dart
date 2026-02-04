part of 'source.dart';

SourceEntity _$SourceEntityFromJson(Map<String, dynamic> json) =>
    SourceEntity(source_id: json['source_id'] as String);

Map<String, dynamic> _$SourceEntityToJson(SourceEntity instance) =>
    <String, dynamic>{'source_id': instance.source_id};
