import 'package:flutter/material.dart';

class SettingsCategory extends StatelessWidget {
  const SettingsCategory({super.key, required this.title, this.topPadding});

  final String title;
  final double? topPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topPadding ?? 0),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const Divider(thickness: 2),
      ],
    );
  }
}
