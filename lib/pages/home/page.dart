import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:im_test/api/api.dart';
import 'package:im_test/entity/msg.dart';
import 'package:im_test/entity/service.dart';
import 'package:im_test/helper/image.dart';
import 'package:im_test/helper/platform.dart';
import 'package:im_test/models/base.dart';
import 'package:im_test/models/user_info.dart';
import 'package:im_test/pages/home/info_card/info_card.dart';
import 'package:im_test/pages/home/msg_list/msg_list.dart';
import 'package:im_test/pages/home/session/session.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import 'input_panel/controller.dart';

part 'controller.dart';

part 'state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  @override
  void dispose() {
    controller.onDispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.onInit(context);
  }

  @override
  Widget build(BuildContext context) {
    final msgList = controller.state.msgList.watch(context),
        content = controller.state.content.watch(context),
        notifyServiceID = controller.state.notifyServiceID.watch(context),
        menuOpen = controller.state.menuOpen.watch(context);

    final serviceList = userInfoManager.serviceList.watch(context),
        currentServiceID = userInfoManager.currentServiceID.watch(context);

    final currentMsgList = computed<List<MsgEntity>>(() {
      if (currentServiceID.isEmpty) {
        return [];
      }

      return msgList[currentServiceID] ?? [];
    });

    final theme = Theme.of(context);

    final platform = baseManager.platform.watch(context);

    final isWindows = computed(() => platform == PlatformType.windows);

    final session = Session(
      open: menuOpen,
      serviceList: serviceList,
      currentServiceID: currentServiceID,
      notifyServiceID: notifyServiceID,
      onTap: (service) => controller.handleServiceTap(service, context),
    );

    final chat = Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: InputPanel(
        body: CustomScrollView(
          controller: controller.msgListController,
          slivers: [
            SliverAppBar(
              scrolledUnderElevation: 0,
              centerTitle: true,
              pinned: true,
              title: IgnorePointer(child: Text("在线客服聊天系统(客服侧)")),
              expandedHeight: kToolbarHeight + 32 + 66,
              leading: IconButton(
                onPressed: controller.handleOpenDrawer,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    menuOpen ? Icons.menu_open : Icons.menu,
                    key: ValueKey(menuOpen),
                  ),
                ),
              ),
              actionsPadding: EdgeInsets.only(right: 12),
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  DragToMoveArea(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: theme.appBarTheme.backgroundColor!.withAlpha(
                            33,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top,
                    ),
                    height: 66,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      spacing: 16,
                      mainAxisAlignment: .center,
                      children: [
                        InfoCard(icon: Icons.person, title: '用户信息'),
                        InfoCard(icon: Icons.person, title: '用户信息'),
                        InfoCard(icon: Icons.person, title: '用户信息'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            MsgList(msgList: currentMsgList()),
          ],
        ),
        textController: controller.textController,
        content: content,
        currentServiceID: currentServiceID,
        onContentChange: controller.handleContentChange,
        onSend: controller.handleSend,
        onSelectImage: controller.handleSelectImage,
      ),
    );

    if (isWindows()) {
      return Row(
        children: [
          session,
          Flexible(flex: 1, child: chat),
        ],
      );
    }

    return AdvancedDrawer(
      backdropColor: Colors.transparent,
      controller: controller.drawerController,
      openRatio: 0.5,
      openScale: 1,
      drawer: session,
      child: chat,
    );
  }
}
