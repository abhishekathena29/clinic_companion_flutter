import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'patient_mobile_nav.dart';
import 'patient_sidebar.dart';

class PatientLayout extends StatelessWidget {
  const PatientLayout({
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
      backgroundColor: AppColors.background,
      bottomNavigationBar: isDesktop
          ? null
          : PatientMobileNav(currentRoute: routeName),
      body: SafeArea(
        bottom: !isDesktop,
        child: Row(
          children: [
            if (isDesktop) PatientSidebar(currentRoute: routeName),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  16,
                  isDesktop ? 32 : 16,
                  isDesktop ? 24 : 16,
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
