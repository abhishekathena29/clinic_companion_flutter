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
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disease Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppColors.borderRadius),
                    border: Border.all(color: AppColors.border),
                    color: AppColors.background,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '6 months',
                        style: TextStyle(fontSize: 12, color: AppColors.foreground),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.expand_more, size: 16, color: AppColors.mutedForeground),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(AppColors.borderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Avg. Sugar',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                                Icon(Icons.trending_down, size: 16, color: AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                text: '118 ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.foreground,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'mg/dL',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('down 12%', style: TextStyle(fontSize: 12, color: AppColors.success)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(AppColors.borderRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Avg. BP',
                                  style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                                ),
                                Icon(Icons.trending_down, size: 16, color: AppColors.success),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '132/82',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('down Improving', style: TextStyle(fontSize: 12, color: AppColors.success)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.border,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= bpData.length) {
                                return const SizedBox.shrink();
                              }
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  bpData[value.toInt()]['month'] as String,
                                  style: TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            bpData.length,
                            (index) => FlSpot(index.toDouble(), bpData[index]['systolic'] as double),
                          ),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            bpData.length,
                            (index) => FlSpot(index.toDouble(), bpData[index]['diastolic'] as double),
                          ),
                          isCurved: true,
                          color: AppColors.info,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppColors.primary, 'Systolic'),
                    const SizedBox(width: 16),
                    _legendDot(AppColors.info, 'Diastolic'),
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
      ],
    );
  }
}
