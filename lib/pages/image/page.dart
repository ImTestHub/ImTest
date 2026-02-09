import 'dart:typed_data';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;

    final theme = Theme.of(context);

    final id = GoRouterState.of(context).pathParameters["id"]!;

    final cover = extra["cover"] as Uint8List?;

    return Scaffold(
      backgroundColor: theme.cardTheme.color,
      body: Stack(
        alignment: Alignment.center,
        children: [
          PhotoView(
            gaplessPlayback: true,
            heroAttributes: PhotoViewHeroAttributes(tag: id),
            imageProvider: MemoryImage(cover!),
          ),
          Positioned(
            left: 16,
            top: 32,
            child: Material(
              clipBehavior: Clip.antiAlias,
              shape: const CircleBorder(),
              child: Ink(
                child: InkWell(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    child: Icon(Icons.close, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
