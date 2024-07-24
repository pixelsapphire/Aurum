import 'package:aurum/data/database.dart';
import 'package:aurum/ui/pages/dashboard/account_view.dart';
import 'package:aurum/ui/pages/dashboard/balance_chart.dart';
import 'package:aurum/ui/pages/dashboard/category_division_chart.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:aurum/ui/widgets/titled_card.dart';
import 'package:aurum/util/time_period.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _grouped = true;

  Widget _buildAccounts(BuildContext context) => AurumCollectionBuilder(
        collection: AurumDatabase.accounts,
        onEmpty: const AccountView.empty(),
        builder: (context, value) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
          itemCount: value.length,
          itemBuilder: (context, index) => AccountView(account: value[index]),
        ),
      );

  Widget _buildBalance(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY',
                    style: TextStyle(
                      color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context),
                      fontSize: 20,
                    ),
                  ),
                  AurumDerivedValueBuilder(
                    value: AurumDatabase.totalBalance,
                    builder: (context, balance) => MoneyLabel(
                      balance ?? 0,
                      suffix: ' PLN',
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                  AurumDerivedValueBuilder(
                    value: AurumDatabase.assetsBalance,
                    builder: (context, balance) => MoneyLabel(
                      balance ?? 0,
                      prefix: '(in assets: ',
                      suffix: ' PLN)',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Grouped by day',
                    style: TextStyle(color: AurumColors.foregroundTertiary(context)),
                  ),
                  CupertinoSwitch(
                    activeColor: CupertinoColors.systemGreen,
                    value: _grouped,
                    onChanged: (grouped) => setState(() => _grouped = grouped),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: BalanceChart(
                  source: _grouped ? AurumDatabase.balanceOverTimeGrouped : AurumDatabase.balanceOverTime,
                  smooth: _grouped,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildExpenses(BuildContext context) => SizedBox(
        height: 300,
        child: AurumDerivedValueBuilder(
          value: AurumDatabase.expensesByCategory(TimePeriod.untilToday(fromTime: DateTime.now().previousMonth.date)),
          builder: (context, data) => data != null
              ? CategoryDivisionChart(
                  data: data,
                  totalLabel: 'Total expenses',
                )
              : const SizedBox(),
        ),
      );

  Widget _buildIncomes(BuildContext context) => SizedBox(
        height: 300,
        child: AurumDerivedValueBuilder(
          value: AurumDatabase.incomesByCategory(TimePeriod.untilToday(fromTime: DateTime.now().previousMonth.date)),
          builder: (context, data) => data != null
              ? CategoryDivisionChart(
                  data: data,
                  totalLabel: 'Total income',
                )
              : const SizedBox(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final accounts = _buildAccounts(context);
    final balance = TitledCard(title: 'Balance', child: _buildBalance(context));
    final expenses = TitledCard(title: 'Monthly expenses', child: _buildExpenses(context));
    final incomes = TitledCard(title: 'Monthly income', child: _buildIncomes(context));
    return PageBase(
      child: MediaQuery.of(context).orientation == Orientation.portrait
          ? Column(children: [accounts, balance, expenses, incomes])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: [accounts, balance])),
                Expanded(child: Column(children: [expenses, incomes]))
              ],
            ),
    );
  }
}
