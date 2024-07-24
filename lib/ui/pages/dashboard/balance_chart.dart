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
      builder: (context, data) {
        if (data == null) return const SizedBox();
        final dataSource = data.entries.where((e) => e.key > DateTime.now().previousMonth.date).toList();
        final interval = data.isNotEmpty ? chartInterval(range: data.values.max(), preferredTicks: 3.5)?.toDouble() : null;
        return SfCartesianChart(
          primaryXAxis: DateTimeAxis(
            dateFormat: DateFormat('dd MMM'),
            labelRotation: 60,
            desiredIntervals: 10,
            majorGridLines: MajorGridLines(width: 1, color: AurumColors.foregroundTertiary(context)),
            labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
          ),
          primaryYAxis: NumericAxis(
            maximum: interval != null ? (data.values.max() / interval).ceil() * interval : null,
            interval: interval,
            labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
          ),
          series: [
            SplineAreaSeries<MapEntry<DateTime, double>, DateTime>(
              splineType: smooth ? SplineType.monotonic : SplineType.cardinal,
              cardinalSplineTension: 0.33,
              dataSource: dataSource,
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
