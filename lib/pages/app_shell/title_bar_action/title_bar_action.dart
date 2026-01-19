import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:im_test/models/base.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class TitleBarAction extends StatelessWidget {
  const TitleBarAction({super.key});

  void handleMinimize() {
    windowManager.minimize();
  }

  void handleMaximize() {
    final isMaximized = baseManager.isMaximized.value;

    baseManager.setIsMaximized(!baseManager.isMaximized.value);

    if (isMaximized) {
      windowManager.unmaximize();

      return;
    }

    windowManager.maximize();
  }

  void handleClose() async {
    windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    final isMaximized = baseManager.isMaximized.watch(context);

    return Positioned(
      right: 16,
      top: 8,
      child: DragToMoveArea(
        child: Row(
          children: [
            IconButton(
              tooltip: "最小化",
              onPressed: handleMinimize,
              icon: const Icon(Symbols.remove),
            ),
            IconButton(
              tooltip: isMaximized ? "还原" : "最大化",
              onPressed: () => handleMaximize(),
              icon: Icon(
                isMaximized
                    ? FluentIcons.window_multiple_16_filled
                    : FluentIcons.maximize_16_filled,
              ),
            ),
            IconButton(
              tooltip: "退出",
              color: Colors.red,
              onPressed: handleClose,
              icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
            ),
          ],
        ),
      ),
    );
  }
}
