import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/ui/pages/more/accounts.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/ui/widgets/money_label.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountView extends StatelessWidget {
  final Account? _account;

  const AccountView({super.key, required Account account}) : _account = account;

  const AccountView.empty({super.key}) : _account = null;

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
            child: Padding(
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
                              background: _account?.color,
                              padding: 6,
                              child: Icon(_account?.icon ?? Icons.block, size: constraints.maxHeight - 12),
                            ),
                          ),
                        ),
                        if (_account != null)
                          Icon(
                            _account.asset ? Icons.attach_money_outlined : Icons.balance_outlined,
                            color: AurumColors.foregroundTertiary(context),
                          ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, _account != null ? 2 : 0),
                    child: Text(
                      _account?.name.toUpperCase() ?? 'NO ACCOUNTS',
                      style: TextStyle(
                        color: _account != null
                            ? AurumColors.foregroundSecondary(context)
                            : AurumColors.foregroundPrimary(context),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (_account != null)
                    AurumDerivedValueBuilder(
                      value: AurumDatabase.accountBalance(_account),
                      builder: (_, balance) => MoneyLabel(balance ?? 0, suffix: ' PLN', style: const TextStyle(fontSize: 28)),
                    ),
                  if (_account == null)
                    Text(
                      _account?.name.toUpperCase() ?? 'You can add an account in the \'More\' tab.',
                      style: TextStyle(color: AurumColors.foregroundSecondary(context), fontSize: 18),
                    )
                ],
              ),
            ),
          ),
        ),
      );
}
