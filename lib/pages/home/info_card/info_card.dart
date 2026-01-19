import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const InfoCard({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Flexible(
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Ink(
          child: InkWell(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Icon(icon),
                  Text(title, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
