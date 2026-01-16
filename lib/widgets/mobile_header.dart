import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MobileHeader extends StatefulWidget {
  const MobileHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showSearch = true,
  });

  final String title;
  final String? subtitle;
  final bool showSearch;

  @override
  State<MobileHeader> createState() => _MobileHeaderState();
}

class _MobileHeaderState extends State<MobileHeader> {
  bool _searchOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: AppColors.gradientPrimary,
                        ),
                        child: const Icon(Icons.favorite, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (widget.showSearch)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _searchOpen = !_searchOpen;
                            });
                          },
                          icon: Icon(Icons.search, color: AppColors.mutedForeground),
                        ),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_searchOpen && widget.showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(AppColors.borderRadius),
                ),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search patients, appointments...',
                    hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                    prefixIcon: Icon(Icons.search, size: 18, color: AppColors.mutedForeground),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
