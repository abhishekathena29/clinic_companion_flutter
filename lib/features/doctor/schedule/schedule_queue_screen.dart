import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/mobile_header.dart';
import '../../../widgets/responsive_page_header.dart';
import '../queue/queue_provider.dart';
import '../queue/queue_screen.dart';
import 'schedule_provider.dart';
import 'schedule_screen.dart';

class ScheduleQueueScreen extends StatefulWidget {
  const ScheduleQueueScreen({
    super.key,
    this.initialTab = 0,
  });

  /// 0 = Schedule & Appointments, 1 = Live Patient Queue
  final int initialTab;

  @override
  State<ScheduleQueueScreen> createState() => _ScheduleQueueScreenState();
}

class _ScheduleQueueScreenState extends State<ScheduleQueueScreen> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab.clamp(0, 1);
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768;

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final doctorId = auth.user?.uid ?? '';
    final queueProvider = context.watch<QueueProvider>();
    final waitingCount = queueProvider.waitingCountFor(doctorId);
    final scheduleProvider = context.watch<ScheduleProvider>();
    final appointments = scheduleProvider.appointmentsForDate(doctorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop)
          const MobileHeader(
            title: 'Schedule & Queue',
            showSearch: false,
          ),
        if (isDesktop)
          const ResponsivePageHeader(
            title: 'Schedule & Live Queue',
            subtitle:
                'Unified appointments calendar, timeline and real-time patient queue',
          ),
        const SizedBox(height: 16),

        // Unified Segmented Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _SegmentTabButton(
                  icon: Icons.calendar_month_rounded,
                  label: 'Appointments Schedule',
                  badgeCount: appointments.length,
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SegmentTabButton(
                  icon: Icons.list_alt_rounded,
                  label: 'Live Patient Queue',
                  badgeCount: waitingCount > 0 ? waitingCount : null,
                  badgeColor: AppColors.warning,
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Active Tab Screen
        if (_selectedTab == 0)
          const ScheduleScreen(showHeader: false)
        else
          const QueueScreen(showHeader: false),
      ],
    );
  }
}

class _SegmentTabButton extends StatelessWidget {
  const _SegmentTabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
    this.badgeColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppColors.mutedForeground,
                  ),
                ),
              ),
              if (badgeCount != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : (badgeColor ?? AppColors.primary).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (badgeColor ?? AppColors.primary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
