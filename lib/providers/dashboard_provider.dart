import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/stat_card.dart';

class DashboardStat {
  const DashboardStat({
    required this.title,
    required this.value,
    required this.change,
    required this.changeType,
    required this.icon,
    required this.variant,
  });

  final String title;
  final String value;
  final String change;
  final StatChangeType changeType;
  final IconData icon;
  final StatVariant variant;
}

class DashboardProvider extends ChangeNotifier {
  final String doctorName = 'Dr. Kumar';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get today => DateFormat('EEEE, d MMMM yyyy', 'en_IN').format(DateTime.now());
  String get shortDate => DateFormat('EEE, d MMM', 'en_IN').format(DateTime.now());

  List<DashboardStat> get stats => const [
        DashboardStat(
          title: "Today's Patients",
          value: '24',
          change: '+3 from yesterday',
          changeType: StatChangeType.positive,
          icon: Icons.people,
          variant: StatVariant.primary,
        ),
        DashboardStat(
          title: 'Appointments',
          value: '18',
          change: '4 remaining today',
          changeType: StatChangeType.neutral,
          icon: Icons.calendar_today,
          variant: StatVariant.info,
        ),
        DashboardStat(
          title: 'Avg. Wait Time',
          value: '18 min',
          change: 'down 5 min from last week',
          changeType: StatChangeType.positive,
          icon: Icons.access_time,
          variant: StatVariant.success,
        ),
        DashboardStat(
          title: 'Pending Follow-ups',
          value: '7',
          change: '3 overdue',
          changeType: StatChangeType.negative,
          icon: Icons.warning_amber,
          variant: StatVariant.warning,
        ),
      ];
}
