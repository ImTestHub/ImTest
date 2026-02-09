import 'package:flutter/material.dart';

class PanelItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PanelItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      spacing: 3,
      children: [
        Material(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            child: InkWell(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                padding: EdgeInsets.all(8),
                child: Icon(icon, size: 24),
              ),
            ),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.textTheme.bodySmall!.color!.withAlpha(160),
          ),
        ),
      ],
    );
  }
}
