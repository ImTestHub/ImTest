import 'package:flutter/material.dart';
import 'package:im_test/helper/platform.dart';
import './title_bar_action/title_bar_action.dart';

class AppShell extends StatelessWidget {
  final Widget page;

  const AppShell({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [page, if (PlatformHelper.isDesktop) TitleBarAction()],
    );
  }
}
