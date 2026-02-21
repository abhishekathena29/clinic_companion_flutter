import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';

class ChronicDiseaseChart extends StatelessWidget {
  const ChronicDiseaseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final bpData = [
      {'month': 'Jan', 'systolic': 148.0, 'diastolic': 92.0},
      {'month': 'Feb', 'systolic': 145.0, 'diastolic': 90.0},
      {'month': 'Mar', 'systolic': 140.0, 'diastolic': 88.0},
      {'month': 'Apr', 'systolic': 138.0, 'diastolic': 85.0},
      {'month': 'May', 'systolic': 135.0, 'diastolic': 84.0},
      {'month': 'Jun', 'systolic': 132.0, 'diastolic': 82.0},
    ];

    return Container(
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.monitor_heart_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Disease Trends',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    color: AppColors.muted.withOpacity(0.5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Last 6 months',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    _TrendCard(
                      title: 'Avg. Sugar',
                      value: '118',
                      unit: 'mg/dL',
                      trend: 'down 12%',
                      isPositive: true,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 16),
                    _TrendCard(
                      title: 'Avg. BP',
                      value: '132/82',
                      unit: 'mmHg',
                      trend: 'Improving',
                      isPositive: true,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 240,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border.withOpacity(0.5),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= bpData.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  bpData[value.toInt()]['month'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedForeground,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.mutedForeground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            bpData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              bpData[index]['systolic'] as double,
                            ),
                          ),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.primary,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            bpData.length,
                            (index) => FlSpot(
                              index.toDouble(),
                              bpData[index]['diastolic'] as double,
                            ),
                          ),
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.accent,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppColors.primary, 'Systolic'),
                    const SizedBox(width: 24),
                    _legendDot(AppColors.accent, 'Diastolic'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TrendCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final String trend;
  final bool isPositive;
  final Color color;

  const _TrendCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.trend,
    required this.isPositive,
    required this.color,
  });

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_isHovered ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppColors.borderRadius),
            border: Border.all(color: widget.color.withOpacity(0.2)),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    widget.isPositive
                        ? Icons.trending_down_rounded
                        : Icons.trending_up_rounded,
                    size: 18,
                    color: widget.color,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: '${widget.value} ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.foreground,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: widget.unit,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.trend,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
