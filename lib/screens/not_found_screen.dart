import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.muted,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('404', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Oops! Page not found',
              style: TextStyle(fontSize: 16, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: Text(
                'Return to Home',
                style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
