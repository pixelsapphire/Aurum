import 'package:aurum/data/database.dart';
import 'package:aurum/ui/pages/dashboard/account_view.dart';
import 'package:aurum/ui/pages/dashboard/balance_chart.dart';
import 'package:aurum/ui/pages/dashboard/category_division_chart.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:aurum/ui/widgets/titled_card.dart';
import 'package:aurum/util/time_period.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  Widget _buildAccounts(BuildContext context) => AurumCollectionBuilder(
        collection: AurumDatabase.accounts,
        onEmpty: const AccountView.empty(),
        builder: (context, value) => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
            childAspectRatio: 1.5,
          ),
          itemCount: value.length,
          itemBuilder: (context, index) => AccountView(account: value[index]),
        ),
      );

  Widget _buildBalance(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY',
            style: TextStyle(color: CupertinoDynamicColor.resolve(CupertinoColors.secondaryLabel, context), fontSize: 20),
          ),
          AurumDerivedValueBuilder(
            value: AurumDatabase.totalBalance,
            builder: (context, balance) => MoneyLabel(balance ?? 0, suffix: ' PLN', style: const TextStyle(fontSize: 36)),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: SizedBox(height: 250, child: Padding(padding: EdgeInsets.only(right: 4), child: BalanceChart())),
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
  Widget build(BuildContext context) => PageBase(
        child: Column(
          children: [
            _buildAccounts(context),
            TitledCard(title: 'Balance', childAlignment: HorizontalAlignment.start, child: _buildBalance(context)),
            TitledCard(title: 'Monthly expenses', childAlignment: HorizontalAlignment.start, child: _buildExpenses(context)),
            TitledCard(title: 'Monthly income', childAlignment: HorizontalAlignment.start, child: _buildIncomes(context)),
          ],
        ),
      );
}
