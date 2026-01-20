import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:im_test/api/api.dart';
import 'package:im_test/entity/msg.dart';
import 'package:im_test/entity/service.dart';
import 'package:im_test/models/base.dart';
import 'package:im_test/models/user_info.dart';
import 'package:im_test/pages/home/info_card/info_card.dart';
import 'package:im_test/pages/home/session/session.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

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
        notifyServiceID = controller.state.notifyServiceID.watch(context);

    final serviceList = userInfoManager.serviceList.watch(context),
        currentServiceID = userInfoManager.currentServiceID.watch(context);

    final currentMsgList = computed<List<MsgEntity>>(() {
      if (currentServiceID.isEmpty) {
        return [];
      }

      return msgList[currentServiceID] ?? [];
    });

    final theme = Theme.of(context);

    final dateList = computed(() => timeLine(currentMsgList()));

    final platform = baseManager.platform.watch(context);

    final isWindows = computed(() => platform == PlatformType.windows);

    final session = Session(
      serviceList: serviceList,
      currentServiceID: currentServiceID,
      notifyServiceID: notifyServiceID,
      onTap: (service) => controller.handleServiceTap(service, context),
    );

    final chat = Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            controller: controller.msgListController,
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                centerTitle: true,
                pinned: true,
                title: IgnorePointer(child: Text("在线客服聊天系统(客服侧)")),
                expandedHeight: kToolbarHeight + 32 + 66,
                leading: !isWindows()
                    ? IconButton(
                        onPressed: controller.handleOpenDrawer,
                        icon: Icon(Icons.menu),
                      )
                    : null,
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
                      margin: EdgeInsets.only(top: kToolbarHeight),
                      height: 66,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 104),
                sliver: SliverList.separated(
                  // controller: controller.msgListController,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final msg = currentMsgList[index];

                    final isSender = msg.type == MsgType.send;

                    final dateIndex = dateList.indexWhere(
                      (e) => e["id"] == msg.id,
                    );

                    return Column(
                      spacing: 8,
                      children: [
                        if (dateIndex != -1)
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withAlpha(33),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            child: Text(
                              dateList[dateIndex]["dateStr"],
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: theme.textTheme.bodySmall!.color!
                                    .withAlpha(200),
                              ),
                            ),
                          ),
                        BubbleNormal(
                          sent: msg.confirmed ?? false,
                          leading: AdvancedAvatar(
                            decoration: BoxDecoration(
                              color: theme.cardTheme.color!.withAlpha(200),
                              shape: BoxShape.circle,
                            ),
                          ),
                          text: msg.content,
                          date: Text(
                            DateUtil.formatDateMs(
                              msg.createAt,
                              format: DateFormats.h_m,
                            ),
                            style: theme.textTheme.bodySmall!.copyWith(
                              color:
                                  (isSender
                                          ? Colors.white
                                          : theme.textTheme.bodySmall!.color!)
                                      .withAlpha(100),
                            ),
                          ),
                          isSender: msg.type == MsgType.send,
                          color: isSender
                              ? theme.colorScheme.primary
                              : theme.cardTheme.color!,
                          tail: true,
                          textStyle: theme.textTheme.bodyMedium!.copyWith(
                            color: isSender ? Colors.white : null,
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: currentMsgList.length,
                ),
              ),
            ],
          ),

          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 88,
                padding: EdgeInsets.symmetric(horizontal: 16),
                color: theme.appBarTheme.backgroundColor!.withAlpha(33),
                child: Row(
                  spacing: 16,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.emoji_emotions),
                    ),
                    Flexible(
                      child: TextFormField(
                        decoration: InputDecoration(hint: Text("请输入")),
                        controller: controller.textController,
                        onChanged: controller.handleContentChange,
                        onEditingComplete: controller.handleSend,
                      ),
                    ),
                    IconButton(
                      onPressed: content.isNotEmpty
                          ? controller.handleSend
                          : null,
                      icon: Icon(
                        Icons.send,
                        color: content.isNotEmpty
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isWindows()) {
      return Row(
        children: [
          Flexible(flex: 1, child: session),
          Flexible(flex: 3, child: chat),
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
