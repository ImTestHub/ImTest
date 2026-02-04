import 'package:json_annotation/json_annotation.dart';

part 'source.g.dart';

class SourceEntity {
  @JsonKey(name: 'source_id')
  final String source_id;

  SourceEntity({required this.source_id});

  // 自动生成的反序列化方法
  factory SourceEntity.fromJson(Map<String, dynamic> json) =>
      _$SourceEntityFromJson(json);

  // 自动生成的序列化方法
  Map<String, dynamic> toJson() => _$SourceEntityToJson(this);
}
