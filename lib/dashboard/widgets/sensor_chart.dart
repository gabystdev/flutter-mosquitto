import 'dart:async'; // Para usar StreamController
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SensorChart extends StatelessWidget {
  final Stream<List<FlSpot>> dataStream;
  final String title;
  final String yAxisTitle;
  final Color lineColor;
  final ChartType chartType;

  const SensorChart.lineChart({
    super.key,
    required this.dataStream,
    required this.title,
    required this.yAxisTitle,
    required this.lineColor,
  }) : chartType = ChartType.line;

  const SensorChart.barChart({
    super.key,
    required this.dataStream,
    required this.title,
    required this.yAxisTitle,
    required this.lineColor,
  }) : chartType = ChartType.bar;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FlSpot>>(
      stream: dataStream, // Se suscribe al stream de datos
      builder: (context, snapshot) {
        // Si el stream está esperando datos o hubo un error
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error al cargar los datos"));
        }

        // Si no hay datos
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Esperando más datos..."));
        }

        // Obtiene los datos visibles según el tipo de gráfico
        final visibleData = _getVisibleData(
          snapshot.data!,
          chartType == ChartType.line ? 20 : 5,
        );

        return Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    chartType == ChartType.line
                        ? LineChartWidget(
                          data: visibleData,
                          lineColor: lineColor,
                        )
                        : BarChartWidget(
                          data: visibleData,
                          lineColor: lineColor,
                        ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _getVisibleData(List<FlSpot> data, int limit) {
    if (data.isEmpty) return [];
    return data.length > limit ? data.sublist(data.length - limit) : data;
  }
}

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> data;
  final Color lineColor;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    double interval = (data.last.x - data.first.x) / 5;
    interval = interval <= 0 ? 1 : interval.ceilToDouble();

    return LineChart(
      LineChartData(
        minX: data.first.x,
        maxX: data.last.x,
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withOpacityX(0.8),
                lineColor.withOpacityX(0.3),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [lineColor.withOpacityX(0.2), Colors.transparent],
              ),
            ),
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: _buildTitles(interval),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

FlTitlesData _buildTitles(double interval) {
  return FlTitlesData(
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget:
            (value, meta) => Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12),
            ),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: interval,
        getTitlesWidget:
            (value, meta) => Text(
              DateFormat(
                'HH:mm:ss',
              ).format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
              style: const TextStyle(fontSize: 10),
            ),
      ),
    ),
  );
}

class BarChartWidget extends StatelessWidget {
  final List<FlSpot> data;
  final Color lineColor;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups:
            data
                .map(
                  (spot) => BarChartGroupData(
                    x: spot.x.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: spot.y,
                        gradient: LinearGradient(
                          colors: [
                            lineColor.withOpacityX(0.9),
                            lineColor.withOpacityX(0.4),
                          ],
                        ),
                        width: 15,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ),
                )
                .toList(),
        titlesData: _buildTitles(1),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

enum ChartType { line, bar }

extension ColorwithOpacityX on Color {
  Color withOpacityX(val) {
    return withValues(alpha: val);
  }
}
