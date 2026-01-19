part of 'login.dart';

LoginEntity _$LoginEntityFromJson(Map<String, dynamic> json) => LoginEntity(
  account: json['account'] as String,
  enable: json['enable'] as bool,
  key: json['key'] as String,
  refresh_token: _$RefreshTokenFromJson(json['refresh_token']),
  token: json['token'] as String,
);

Map<String, dynamic> _$LoginEntityToJson(LoginEntity instance) =>
    <String, dynamic>{
      'account': instance.account,
      'enable': instance.enable,
      'key': instance.key,
      'refresh_token': instance.refresh_token,
      'token': instance.token,
    };

RefreshToken _$RefreshTokenFromJson(Map<String, dynamic> json) => RefreshToken(
  expired_at: json['expired_at'] as int,
  token: json['token'] as String,
);

Map<String, dynamic> _$RefreshTokenToJson(RefreshToken instance) =>
    <String, dynamic>{
      'expired_at': instance.expired_at,
      'token': instance.token,
    };
