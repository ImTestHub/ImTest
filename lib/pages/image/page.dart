import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;

    final theme = Theme.of(context);

    final cover = extra["cover"] as Uint8List?;

    return GestureDetector(
      onTap: () => context.pop(),
      child: Scaffold(
        backgroundColor: theme.cardTheme.color,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Hero(
                tag: "image",
                child: Image.memory(
                  cover!,
                  gaplessPlayback: true,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
