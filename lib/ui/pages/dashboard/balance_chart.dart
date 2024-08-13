import 'dart:collection';
import 'package:aurum/data/database.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalanceChart extends StatelessWidget {
  final AurumDerivedValue<LinkedHashMap<DateTime, double>> source;
  final bool smooth;

  const BalanceChart({super.key, required this.source, this.smooth = true});

  @override
  Widget build(BuildContext context) {
    final color = CupertinoColors.systemIndigo.withValue(1);
    final gradient = LinearGradient(
      colors: [
        CupertinoColors.systemIndigo.withValue(1).withOpacity(0.4),
        CupertinoColors.systemIndigo.withValue(1).withOpacity(0),
      ],
      stops: const [0, 1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    return AurumDerivedValueBuilder(
      value: source,
      builder: (context, sourceData) {
        if (sourceData == null) return const SizedBox();
        final data = sourceData.whereKey((time) => time > DateTime.now().previousMonth.date);
        final range = data.isNotEmpty ? data.values.max() - min(data.values.min(), 0.0) : 0.0;
        final interval = data.isNotEmpty ? chartInterval(range: range, preferredTicks: 3.5)?.toDouble() : null;
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('dd MMM'),
            labelRotation: 60,
            desiredIntervals: 10,
            majorGridLines: MajorGridLines(width: 1, color: AurumColors.foregroundTertiary(context)),
            labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
          ),
          primaryYAxis: NumericAxis(
            minimum: interval != null ? (data.values.min() / interval).floor() * interval : null,
            maximum: interval != null ? (data.values.max() / interval).ceil() * interval : null,
            interval: interval,
            labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
          ),
          series: [
            SplineAreaSeries<MapEntry<DateTime, double>, DateTime>(
              splineType: smooth ? SplineType.monotonic : SplineType.cardinal,
              cardinalSplineTension: 0.33,
              dataSource: data.entries.toList(),
              xValueMapper: (entry, _) => entry.key,
              yValueMapper: (entry, _) => entry.value,
              animationDuration: 0,
              borderColor: color,
              gradient: gradient,
            )
          ],
        );
      },
    );
  }
}
