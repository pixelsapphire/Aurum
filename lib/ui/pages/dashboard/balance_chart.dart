import 'package:aurum/data/database.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalanceChart extends StatelessWidget {
  const BalanceChart({super.key});

  @override
  Widget build(BuildContext context) => AurumDerivedValueBuilder(
        value: AurumDatabase.balanceOverTime,
        builder: (context, data) => data == null
            ? const SizedBox()
            : SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  dateFormat: DateFormat('dd MMM'),
                  labelRotation: 60,
                  desiredIntervals: 10,
                  majorGridLines: MajorGridLines(width: 1, color: AurumColors.foregroundTertiary(context)),
                  labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
                ),
                primaryYAxis: NumericAxis(
                  interval: data.isNotEmpty ? chartInterval(range: data.values.max(), preferredTicks: 3.5).toDouble() : null,
                  labelStyle: TextStyle(color: AurumColors.foregroundSecondary(context)),
                ),
                series: [
                  SplineAreaSeries<MapEntry<DateTime, double>, DateTime>(
                    splineType: SplineType.monotonic,
                    dataSource: data.entries.where((e) => e.key > DateTime.now().previousMonth.date).toList(),
                    xValueMapper: (entry, _) => entry.key,
                    yValueMapper: (entry, _) => entry.value,
                    animationDuration: 0,
                    borderColor: CupertinoColors.systemIndigo.withValue(1),
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemIndigo.withValue(1).withOpacity(0.4),
                        CupertinoColors.systemIndigo.withValue(1).withOpacity(0),
                      ],
                      stops: const [0, 1],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
      );
}
