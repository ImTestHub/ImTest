import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:im_test/entity/msg.dart';
import 'package:signals/signals.dart';

import '../../../components/source_image/source_image.dart';

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

class MsgList extends StatelessWidget {
  final List<MsgEntity> msgList;

  const MsgList({super.key, required this.msgList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateList = computed(() => timeLine(msgList));

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 104),
      sliver: SliverList.separated(
        separatorBuilder: (context, index) => SizedBox(height: 16),
        itemBuilder: (context, index) {
          final msg = msgList[index];

          final isSender = msg.type == MsgType.send;

          final dateIndex = dateList.indexWhere((e) => e["id"] == msg.id);

          return Column(
            spacing: 8,
            children: [
              if (dateIndex != -1)
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(33),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    dateList[dateIndex]["dateStr"],
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: theme.textTheme.bodySmall!.color!.withAlpha(200),
                    ),
                  ),
                ),
              if (msg.contentType == ContentType.text)
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
                )
              else if (msg.contentType == ContentType.image)
                BubbleNormalImage(
                  color: isSender
                      ? theme.colorScheme.primary
                      : theme.cardTheme.color!,
                  tail: true,
                  sent: msg.confirmed ?? false,
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
                  leading: AdvancedAvatar(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color!.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                  ),
                  image: SourceImage(
                    tag: "image",
                    sourceID: msg.content,
                    onTap: (cover) => context.push(
                      "/image/${msg.id}",
                      extra: {"cover": cover},
                    ),
                  ),
                ),
            ],
          );
        },
        itemCount: msgList.length,
      ),
    );
  }
}
