import 'package:aurum/data/objects/category.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CategoryDivisionChart extends StatefulWidget {
  final Map<Category, double> data;
  final String totalLabel;

  const CategoryDivisionChart({super.key, required this.data, required this.totalLabel});

  @override
  State<CategoryDivisionChart> createState() => _CategoryDivisionChartState();
}

class _CategoryDivisionChartState extends State<CategoryDivisionChart> {
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) => widget.data.entries.toList().op(
        (entries) {
          final double total = sum(entries.map((e) => e.value));
          return Stack(
            children: [
              SfCircularChart(
                palette: entries
                    .map((e) => e.key.color.opIf(_selectedCategory != null && e.key != _selectedCategory,
                        (c) => c.withValue(e.key.color.getValue() * 0.5)))
                    .nullIfEmpty()
                    ?.toList(),
                series: [
                  DoughnutSeries<MapEntry<Category, double>, String>(
                    dataSource: entries,
                    xValueMapper: (entry, _) => entry.key.name,
                    yValueMapper: (entry, _) => entry.value,
                    radius: '100%',
                    innerRadius: '70%',
                    animationDuration: 0,
                    onPointTap: (slice) => setState(() {
                      final tappedCategory = slice.pointIndex != null ? entries[slice.pointIndex!].key : null;
                      _selectedCategory = _selectedCategory == tappedCategory ? null : tappedCategory;
                    }),
                  ),
                ],
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      _selectedCategory?.name ?? widget.totalLabel,
                      style: TextStyle(color: AurumColors.foregroundSecondary(context), fontSize: 20),
                    ),
                    MoneyLabel(
                      _selectedCategory != null
                          ? widget.data[_selectedCategory]?.abs() ?? 0
                          : widget.data.values.nullIfEmpty()?.reduce((a, b) => a + b).abs() ?? 0,
                      suffix: ' PLN',
                      style: const TextStyle(fontSize: 30),
                    ),
                    Text(
                      _selectedCategory != null ? ((widget.data[_selectedCategory] ?? 0) / total).asPercent(1) : '',
                      style: TextStyle(color: AurumColors.foregroundPrimary(context), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
}
