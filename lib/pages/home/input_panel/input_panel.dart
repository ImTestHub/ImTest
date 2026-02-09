part of 'controller.dart';

class InputPanel extends StatefulWidget {
  final TextEditingController textController;
  final String content;
  final Widget body;
  final String currentServiceID;
  final Function(String) onContentChange;
  final VoidCallback onSend;
  final VoidCallback onSelectImage;

  const InputPanel({
    super.key,
    required this.textController,
    required this.content,
    required this.body,
    required this.currentServiceID,
    required this.onContentChange,
    required this.onSend,
    required this.onSelectImage,
  });

  @override
  State<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<InputPanel> {
  final controller = InputPanelController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit();
  }

  @override
  void dispose() {
    controller.onDispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final panelOpen = controller.panelOpen.watch(context);

    final keyboardHeight = baseManager.keyboardHeight.watch(context),
        keyboardVisible = baseManager.keyboardVisible.watch(context);

    final double height = PlatformHelper.isDesktop ? 66 : 88;

    final double maxHeight =
        MediaQuery.of(context).size.height *
        (PlatformHelper.isDesktop ? 0.25 : 0.5);

    final platform = baseManager.platform.watch(context);

    final isWindows = computed(() => platform == PlatformType.windows);

    final input = Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        8,
        MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: TextFormField(
              focusNode: controller.focusNode,
              decoration: InputDecoration(hint: Text("请输入")),
              controller: widget.textController,
              onChanged: widget.onContentChange,
              onEditingComplete: widget.onSend,
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.emoji_emotions)),
              IconButton(
                onPressed: controller.handleTogglePanel,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    key: ValueKey(panelOpen),
                    panelOpen ? Icons.close : Icons.add,
                  ),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            decoration: BoxDecoration(),
            clipBehavior: Clip.antiAlias,
            width: (!isWindows() && widget.content.isNotEmpty) ? null : 0,
            duration: const Duration(milliseconds: 600),
            child: IconButton(
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
          ),
        ],
      ),
    );

    return ClipRect(
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: SlidingUpPanel(
          onPanelOpened: controller.handlePanelOpened,
          onPanelClosed: controller.handlePanelClosed,
          controller: controller.panelController,
          minHeight: keyboardVisible ? keyboardHeight + height : height,
          boxShadow: const [],
          maxHeight: maxHeight,
          color: theme.appBarTheme.backgroundColor!.withAlpha(200),
          body: widget.body,
          panel: ClipRect(
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  input,
                  Flexible(
                    child: Container(
                      height: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PanelItem(
                            icon: Icons.photo,
                            label: "图片",
                            onTap: widget.onSelectImage,
                          ),
                          PanelItem(
                            icon: Icons.folder,
                            label: "文件",
                            onTap: widget.onSelectImage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
