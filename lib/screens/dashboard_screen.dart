import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/alerts_panel.dart';
import '../widgets/chronic_disease_chart.dart';
import '../widgets/dashboard_layout.dart';
import '../widgets/header.dart';
import '../widgets/mobile_header.dart';
import '../widgets/queue_list.dart';
import '../widgets/recent_patients.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_appointments.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final today = DateFormat('EEEE, d MMMM yyyy', 'en_IN').format(DateTime.now());
    final shortDate = DateFormat('EEE, d MMM', 'en_IN').format(DateTime.now());

    return DashboardLayout(
      routeName: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            MobileHeader(
              title: 'Good Morning, Dr. Kumar',
              subtitle: shortDate,
            ),
          if (isDesktop)
            Header(
              title: 'Good Morning, Dr. Kumar',
              subtitle: today,
            ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            mainAxisSpacing: isDesktop ? 24 : 12,
            crossAxisSpacing: isDesktop ? 24 : 12,
            childAspectRatio: isDesktop ? 1.6 : 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              StatCard(
                title: "Today's Patients",
                value: '24',
                change: '+3 from yesterday',
                changeType: StatChangeType.positive,
                icon: Icons.people,
                variant: StatVariant.primary,
              ),
              StatCard(
                title: 'Appointments',
                value: '18',
                change: '4 remaining today',
                changeType: StatChangeType.neutral,
                icon: Icons.calendar_today,
                variant: StatVariant.info,
              ),
              StatCard(
                title: 'Avg. Wait Time',
                value: '18 min',
                change: 'down 5 min from last week',
                changeType: StatChangeType.positive,
                icon: Icons.access_time,
                variant: StatVariant.success,
              ),
              StatCard(
                title: 'Pending Follow-ups',
                value: '7',
                change: '3 overdue',
                changeType: StatChangeType.negative,
                icon: Icons.warning_amber,
                variant: StatVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: QueueList()),
                SizedBox(width: 24),
                Expanded(child: AlertsPanel()),
              ],
            )
          else
            Column(
              children: const [
                QueueList(),
                SizedBox(height: 16),
                AlertsPanel(),
              ],
            ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: ChronicDiseaseChart()),
                SizedBox(width: 24),
                Expanded(child: UpcomingAppointments()),
              ],
            )
          else
            Column(
              children: const [
                ChronicDiseaseChart(),
                SizedBox(height: 16),
                UpcomingAppointments(),
              ],
            ),
          const SizedBox(height: 24),
          const RecentPatients(),
        ],
      ),
    );
  }
}
