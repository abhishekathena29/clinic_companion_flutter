import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitle!,
                  style: TextStyle(color: AppColors.mutedForeground),
                ),
              ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 288,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppColors.borderRadius),
                border: Border.all(color: AppColors.border),
                color: AppColors.background,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search patients, appointments...',
                  hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                  prefixIcon: Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications, color: AppColors.mutedForeground),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const AppButton(label: 'New Patient', icon: Icons.add),
          ],
        ),
      ],
    );
  }
}
