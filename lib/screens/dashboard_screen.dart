import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
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
    final provider = context.watch<DashboardProvider>();
    final today = provider.today;
    final shortDate = provider.shortDate;
    final greeting = provider.greeting;

    return DashboardLayout(
      routeName: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop)
            MobileHeader(
              title: '$greeting, ${provider.doctorName}',
              subtitle: shortDate,
            ),
          if (isDesktop)
            Header(
              title: '$greeting, ${provider.doctorName}',
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
            children: provider.stats
                .map((stat) => StatCard(
                      title: stat.title,
                      value: stat.value,
                      change: stat.change,
                      changeType: stat.changeType,
                      icon: stat.icon,
                      variant: stat.variant,
                    ))
                .toList(),
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
