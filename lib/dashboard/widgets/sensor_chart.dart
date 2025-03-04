import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SensorChart extends StatelessWidget {
  final List<FlSpot> data;
  final String title;
  final String yAxisTitle;
  final Color lineColor;
  final ChartType chartType;

  const SensorChart.lineChart({
    super.key,
    required this.data,
    required this.title,
    required this.yAxisTitle,
    required this.lineColor,
  }) : chartType = ChartType.line;

  const SensorChart.barChart({
    super.key,
    required this.data,
    required this.title,
    required this.yAxisTitle,
    required this.lineColor,
  }) : chartType = ChartType.bar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 24)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                chartType == ChartType.line
                    ? LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: data,
                            isCurved: true,
                            color: lineColor,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 10,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 60000,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    )
                    : BarChart(
                      BarChartData(
                        barGroups:
                            data
                                .map(
                                  (spot) => BarChartGroupData(
                                    x: spot.x.toInt(),
                                    barRods: [
                                      BarChartRodData(
                                        toY: spot.y,
                                        color: lineColor,
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 10,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 60000,
                            ),
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

enum ChartType { line, bar }
