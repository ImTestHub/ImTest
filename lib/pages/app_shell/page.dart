import 'package:flutter/material.dart';
import './title_bar_action/title_bar_action.dart';

class AppShell extends StatelessWidget {
  final Widget page;

  const AppShell({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [page, TitleBarAction()],
      ),
    );
  }
}
