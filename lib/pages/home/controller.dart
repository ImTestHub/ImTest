part of 'page.dart';

List<Map<String, dynamic>> timeLine(
  List<MsgEntity> items, {
  String dateFormat = 'yyyy-MM-dd',
}) {
  final Map<String, Map<String, dynamic>> dayMap = {};

  for (final item in items) {
    final dateStr = DateUtil.formatDateMs(
      item.createAt,
      format: DateFormats.y_mo_d,
    );

    if (!dayMap.containsKey(dateStr) ||
        item.createAt < dayMap[dateStr]!["timestamp"]) {
      dayMap[dateStr] = {
        "timestamp": item.createAt,
        "id": item.id,
        "dateStr": dateStr,
      };
    }
  }

  return dayMap.values.toList()
    ..sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));
}

class HomeController {
  WebSocketChannel? socket;

  final panelController = PanelController();

  final _winNotifyPlugin = WindowsNotification(applicationId: "在线客服聊天系统(客服侧)");

  late final EffectCleanup socketEffect;

  StreamSubscription<dynamic>? streamListener;

  final state = HomeState();

  final textController = TextEditingController();

  final AdvancedDrawerController drawerController = AdvancedDrawerController();

  final serverUrl = computed(() {
    if (baseManager.env.isEmpty) {
      return '10.138.20.96:9890';
    }

    return baseManager.env.replaceAll("http://", "");
  });

  final ScrollController msgListController = ScrollController();

  void updateMsg({String? serviceID, required List<MsgEntity> value}) {
    final currentServiceID =
        serviceID ?? userInfoManager.currentServiceID.value;

    if (state.msgList.value.containsKey(serviceID)) {
      state.msgList.update(currentServiceID, (_) => value);
    } else {
      state.msgList.value.putIfAbsent(currentServiceID, () => value);
    }
  }

  void showNotification(String content) {
    NotificationMessage notification = NotificationMessage.fromPluginTemplate(
      "test1",
      "有新消息",
      content,
    );

    _winNotifyPlugin.showNotificationPluginTemplate(notification);
  }

  void handleServiceTap(ServiceEntity service, BuildContext context) {
    userInfoManager.setCurrentServiceID(service.service_id);

    if (state.notifyServiceID.value.contains(service.service_id)) {
      state.notifyServiceID.value = state.notifyServiceID.value
        ..remove(service.service_id);
    }

    drawerController.hideDrawer();
  }

  Future<void> handleSelectImage() async {
    final res = await ImageHelper().selectImage();

    if (res != null) {
      final data = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          res["data"],
          filename: res["file"].name,
        ),
      });

      final uploadRes = await API.upload(data);

      final sendid = DateTime.now().millisecondsSinceEpoch;

      socket!.sink.add(
        jsonEncode({
          "msgtype": "image",
          "url": {"url": uploadRes.source_id},
          "sendid": sendid,
          "serviceId": userInfoManager.currentServiceID.value,
        }),
      );

      final List<MsgEntity> currentMsgList = List.from(
        state.msgList.value[userInfoManager.currentServiceID.value] ?? [],
      );

      currentMsgList.add(
        MsgEntity(
          id: sendid,
          content: uploadRes.source_id,
          type: MsgType.send,
          contentType: ContentType.image,
          createAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      updateMsg(
        serviceID: userInfoManager.currentServiceID.value,
        value: currentMsgList,
      );
    }
  }

  void handleOpenDrawer() {
    final isWindows = baseManager.platform.value == PlatformType.windows;

    if (isWindows) {
      state.menuOpen.value = !state.menuOpen.value;
    } else {
      drawerController.toggleDrawer();
    }
  }

  void handleContentChange(String value) {
    state.content.value = value;
  }

  void handleSend() {
    if (socket == null) {
      SmartDialog.showToast('服务未连接');

      return;
    }

    final text = textController.text.trim();

    if (text.isEmpty || userInfoManager.currentServiceID.value.isEmpty) {
      return;
    }

    final sendid = DateTime.now().millisecondsSinceEpoch;

    socket!.sink.add(
      jsonEncode({
        "msgtype": "text",
        "text": {"text": text},
        "sendid": sendid,
        "serviceId": userInfoManager.currentServiceID.value,
      }),
    );

    textController.clear();

    state.content.value = "";

    final List<MsgEntity> currentMsgList = List.from(
      state.msgList.value[userInfoManager.currentServiceID.value] ?? [],
    );

    currentMsgList.add(
      MsgEntity(
        id: sendid,
        content: text,
        type: MsgType.send,
        contentType: ContentType.text,
        createAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    updateMsg(
      serviceID: userInfoManager.currentServiceID.value,
      value: currentMsgList,
    );
  }

  void unloadSocket() {
    socket!.sink.close();

    socket = null;

    if (streamListener != null) streamListener!.cancel();
  }

  Future<void> setupSocket(BuildContext context) async {
    socket = WebSocketChannel.connect(
      Uri.parse('ws://$serverUrl/ws?token=${userInfoManager.token}'),
    );

    await socket!.ready;

    socket!.sink.add(jsonEncode({"msgtype": "event_staff_online"}));

    streamListener = socket!.stream.listen((res) async {
      final message = jsonDecode(res);

      final msgtype = message?["msgtype"],
          sendid = message?['sendid'],
          msgid = message?['msgid'],
          code = message?["code"],
          service_id = message?["serviceId"];

      final List<MsgEntity> currentMsgList = List.from(
        state.msgList.value[service_id] ?? [],
      );

      if (msgtype == "event_staff_enter") {
        userInfoManager.refreshServiceList();
      } else if (msgtype == "msg_confirm") {
        final index = currentMsgList.indexWhere(
          (msg) => msg.id.toString() == sendid.toString(),
        );

        if (index != -1) {
          currentMsgList.replaceRange(index, index + 1, [
            currentMsgList[index].copyWith(
              id: int.parse(msgid),
              confirmed: true,
            ),
          ]);

          updateMsg(serviceID: service_id, value: currentMsgList);
        }
      } else if (msgtype == "text") {
        if (!await windowManager.isFocused()) {
          showNotification(message["text"]['text']);
        }

        if (userInfoManager.currentServiceID.value != service_id) {
          state.notifyServiceID.value = [
            ...state.notifyServiceID.value,
            service_id,
          ];
        }

        currentMsgList.add(
          MsgEntity(
            id: int.parse(msgid),
            content: message["text"]['text'],
            type: MsgType.receive,
            contentType: ContentType.text,
            createAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        updateMsg(serviceID: service_id, value: currentMsgList);
      }

      if (code == 4001 || code == 4002 || code == 4003) {
        API.refreshToken(userInfoManager.token.value).then((res) {
          socket = WebSocketChannel.connect(
            Uri.parse('ws://$serverUrl/ws?token=$res'),
          );

          userInfoManager.setToken(res);
        });
      } else if (code != null && code != 4000) {
        unloadSocket();

        context.replace("/");
      }

      if (msgListController.position.maxScrollExtent > 0) {
        msgListController.jumpTo(
          msgListController.position.maxScrollExtent + 100,
        );
      }
    });
  }

  void onDispose() {
    socketEffect();
  }

  void onInit(BuildContext context) {
    windowManager.setSize(const Size(1600, 900));
    windowManager.center();

    socketEffect = effect(() async {
      if (userInfoManager.token.value.isNotEmpty) {
        setupSocket(context);
      }

      if (userInfoManager.token.value.isEmpty) {
        if (socket != null) {
          unloadSocket();

          context.replace("/");
        }

        return;
      }

      setupSocket(context);
    });
  }
}
