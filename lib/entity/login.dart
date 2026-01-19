import 'package:json_annotation/json_annotation.dart';

part 'login.g.dart';

class RefreshToken {
  final int expired_at;

  final String token;

  const RefreshToken({required this.expired_at, required this.token});
}

// 添加注解
@JsonSerializable()
class LoginEntity {
  // 字段名映射（处理大小写不一致）
  @JsonKey(name: 'account')
  final String account;

  @JsonKey(name: 'enable')
  final bool enable;

  @JsonKey(name: 'key')
  final String key;

  @JsonKey(name: 'refresh_token')
  final RefreshToken refresh_token;

  @JsonKey(name: 'token')
  final String token;

  LoginEntity({
    required this.account,
    required this.enable,
    required this.key,
    required this.refresh_token,
    required this.token,
  });

  // 自动生成的反序列化方法
  factory LoginEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginEntityFromJson(json);

  // 自动生成的序列化方法
  Map<String, dynamic> toJson() => _$LoginEntityToJson(this);
}
