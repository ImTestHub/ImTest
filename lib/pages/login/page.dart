import 'package:flutter/material.dart';
import 'package:im_test/pages/login/controller.dart';

final loginController = LoginController();

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Form(
        key: loginController.formKey,
        child: Center(
          child: Container(
            width: 400,
            height: 600,
            color: theme.cardTheme.color,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32),
                  child: Text("登录页", style: theme.textTheme.titleMedium),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    spacing: 32,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: loginController.userNameController,
                        decoration: InputDecoration(labelText: "用户名"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        controller: loginController.pwdController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: "密码"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        controller: loginController.envController,
                        decoration: InputDecoration(labelText: "环境url"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入环境url';
                          }

                          return null;
                        },
                      ),
                      FilledButton(
                        onPressed: () => loginController.handleSubmit(context),
                        child: Text("登录"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
