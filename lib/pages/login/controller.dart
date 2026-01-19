import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:im_test/api/login.dart';
import 'package:im_test/http/init.dart';
import 'package:im_test/models/base.dart';
import 'package:im_test/models/user_info.dart';

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey();

  final userNameController = TextEditingController();

  final pwdController = TextEditingController();

  final envController = TextEditingController();

  void handleSubmit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      baseManager.setEnv(envController.text);

      Request().setBaseUrl(envController.text);

      LoginAPI.staff({
        "device": "mobile",
        "username": userNameController.text,
        "password": pwdController.text,
      }).then((res) async {
        SmartDialog.showToast("登录成功");

        userInfoManager.setToken(res.token);

        userInfoManager.setAccount(res.account);

        userInfoManager.refreshServiceList();

        context.replace("/home");
      });
    }
  }
}
