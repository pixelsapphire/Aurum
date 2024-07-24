import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/ui/pages/more/accounts.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:aurum/ui/widgets/placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  final Account? _account;

  const AccountView({super.key, required Account account}) : _account = account;

  const AccountView.empty({super.key}) : _account = null;

  Widget _buildDefault(BuildContext context, Account account) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) => SquareIcon(
                        background: account.color,
                        padding: 6,
                        child: Icon(account.icon, size: constraints.maxHeight - 12),
                      ),
                    ),
                  ),
                  Icon(
                    account.asset ? Icons.attach_money_outlined : Icons.balance_outlined,
                    color: AurumColors.foregroundTertiary(context),
                  )
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Text(
                account.name.toUpperCase(),
                style: TextStyle(color: AurumColors.foregroundSecondary(context), fontSize: 18),
              ),
            ),
            AurumDerivedValueBuilder(
              value: AurumDatabase.accountBalance(account),
              builder: (_, balance) => MoneyLabel(balance ?? 0, suffix: ' PLN', style: const TextStyle(fontSize: 28)),
            )
          ],
        ),
      );

  Widget _buildEmpty(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmptyListPlaceholder(
              icon: Icons.wallet_outlined,
              title: 'No accounts',
              message: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'You can add an account by going to '),
                    TextSpan(text: 'More > Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' or by tapping here.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (BuildContext context) => const Accounts())),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: CupertinoDynamicColor.resolve(CupertinoColors.secondarySystemBackground, context),
            ),
            child: _account != null ? _buildDefault(context, _account) : _buildEmpty(context),
          ),
        ),
      );
}
