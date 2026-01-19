import 'dart:convert';

import 'package:im_test/entity/login.dart';
import 'package:im_test/http/init.dart';

class LoginAPI {
  static Future<LoginEntity> staff(Map<String, dynamic> params) async {
    final res = await Request().post<String>("/login/staff", data: params);

    return LoginEntity.fromJson(jsonDecode(res.data)["data"]);
  }
}
