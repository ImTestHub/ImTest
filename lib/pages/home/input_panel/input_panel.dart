import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:im_test/components/sliding_up_panel/sliding_up_panel.dart';
import 'package:signals/signals_flutter.dart';

class InputPanel extends StatefulWidget {
  final TextEditingController textController;
  final String content;
  final String currentServiceID;
  final Function(String) onContentChange;
  final VoidCallback onSend;
  final VoidCallback onSelectImage;

  const InputPanel({
    super.key,
    required this.textController,
    required this.content,
    required this.currentServiceID,
    required this.onContentChange,
    required this.onSend,
    required this.onSelectImage,
  });

  @override
  State<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<InputPanel> {
  final panelOpen = signal(false);

  final controller = PanelController();

  void handleTogglePanel() {
    if (controller.isPanelOpen) {
      controller.close();
    } else {
      controller.open();
    }

    panelOpen.value = !panelOpen.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final _panelOpen = panelOpen.watch(context);

    final input = ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          height: 88,
          padding: EdgeInsets.symmetric(horizontal: 16),
          color: theme.appBarTheme.backgroundColor!.withAlpha(100),
          child: Row(
            spacing: 16,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.emoji_emotions),
                  ),
                  IconButton(
                    onPressed: handleTogglePanel,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        key: ValueKey(_panelOpen),
                        _panelOpen ? Icons.close : Icons.add,
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(hint: Text("请输入")),
                  controller: widget.textController,
                  onChanged: widget.onContentChange,
                  onEditingComplete: widget.onSend,
                ),
              ),
              IconButton(
                onPressed:
                    widget.content.isNotEmpty &&
                        widget.currentServiceID.isNotEmpty
                    ? widget.onSend
                    : null,
                icon: Icon(
                  Icons.send,
                  color:
                      widget.content.isNotEmpty &&
                          widget.currentServiceID.isNotEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SlidingUpPanel(
      controller: controller,
      minHeight: 88,
      maxHeight: MediaQuery.of(context).size.height * 0.3,
      color: theme.appBarTheme.backgroundColor!.withAlpha(100),
      panel: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          input,
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Material(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  child: Ink(
                    child: InkWell(
                      onTap: widget.onSelectImage,
                      child: Container(
                        width: 88,
                        height: 88,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          spacing: 4,
                          children: [Icon(Icons.photo, size: 32), Text("图片")],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const SizedBox(),
      collapsed: input,
    );
  }
}
