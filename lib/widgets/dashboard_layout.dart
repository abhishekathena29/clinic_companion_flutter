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

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);

    return Scaffold(
      extendBody: !isDesktop,
      backgroundColor: AppColors.background,
      body: Row(
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
      bottomNavigationBar: isDesktop
          ? null
          : MobileNav(currentRoute: routeName),
    );
  }
}
