import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'mobile_nav.dart';
import 'sidebar.dart';

class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    super.key,
    required this.child,
    required this.routeName,
  });

  final Widget child;
  final String routeName;

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Row(
            children: [
              if (isDesktop) const Sidebar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 16,
                    16,
                    isDesktop ? 32 : 16,
                    isDesktop ? 24 : 96,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
          if (!isDesktop)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MobileNav(currentRoute: routeName),
            ),
        ],
      ),
    );
  }
}
