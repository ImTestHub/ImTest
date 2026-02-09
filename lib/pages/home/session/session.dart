import 'package:flutter/material.dart';
import 'package:im_test/entity/service.dart';
import 'package:im_test/helper/platform.dart';
import 'package:im_test/models/base.dart';
import 'package:signals/signals_flutter.dart';

class Session extends StatelessWidget {
  final bool open;
  final List<ServiceEntity> serviceList;
  final String? currentServiceID;
  final List<String> notifyServiceID;
  final Function(ServiceEntity) onTap;

  const Session({
    super.key,
    required this.open,
    required this.serviceList,
    required this.currentServiceID,
    required this.notifyServiceID,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: (PlatformHelper.isDesktop && open) ? width * 0.2 : 0,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top,
        16,
        0,
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.onSurface.withAlpha(33),
            width: 1,
          ),
        ),
        color: theme.cardTheme.color,
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            height: kToolbarHeight,
            child: Text(
              "会话列表",
              style: theme.textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          if (serviceList.isEmpty)
            Flexible(
              child: Center(
                child: Text(
                  "暂无会话",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final service = serviceList[index];
                  final active = service.service_id == currentServiceID;

                  return Card(
                    color: active
                        ? theme.colorScheme.primaryContainer
                        : theme.scaffoldBackgroundColor,
                    child: ListTile(
                      title: Text(
                        service.service_id,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: active ? Colors.white : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: notifyServiceID.contains(service.service_id)
                          ? Text("有新消息")
                          : null,
                      onTap: () => onTap(service),
                    ),
                  );
                },
                itemCount: serviceList.length,
              ),
            ),
        ],
      ),
    );
  }
}
