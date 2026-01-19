import 'package:flutter/material.dart';
import 'package:im_test/entity/service.dart';

class Session extends StatelessWidget {
  final List<ServiceEntity> serviceList;
  final String? currentServiceID;
  final Function(ServiceEntity) onTap;

  const Session({
    super.key,
    required this.serviceList,
    required this.currentServiceID,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
            child: Text("会话列表", style: theme.textTheme.titleMedium),
          ),
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
                    ),
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
