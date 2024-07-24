import 'package:aurum/data/database.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:aurum/ui/widgets/titled_card.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/time_period.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Statistics extends StatelessWidget {
  const Statistics({super.key});

  Widget _buildAverage(BuildContext context) => TitledCard(
        title: 'Average daily expenses',
        alignment: HorizontalAlignment.start,
        child: Column(
          children: [
            AurumDerivedValueBuilder(
              value: AurumDatabase.averageDailyExpenses(TimePeriod.untilToday(fromTime: DateTime.now().previousMonth.date)),
              builder: (context, value) => Table(
                columnWidths: const {0: FlexColumnWidth(1), 1: IntrinsicColumnWidth()},
                defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                children: [
                  TableRow(children: [
                    const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('mean')),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MoneyLabel(-(value?.mean ?? 0), suffix: ' PLN', style: const TextStyle(fontSize: 20)),
                    ),
                  ]),
                  TableRow(children: [
                    const FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('median')),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MoneyLabel(-(value?.median ?? 0), suffix: ' PLN', style: const TextStyle(fontSize: 20)),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '*analyzed categories only',
                    style: TextStyle(color: AurumColors.foregroundTertiary(context)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => PageBase(
        navigationBar: const CupertinoNavigationBar(middle: Text('Statistics')),
        child: MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
          itemCount: 1,
          itemBuilder: (context, index) => {
            0: _buildAverage(context),
          }[index]!,
        ),
      );
}
