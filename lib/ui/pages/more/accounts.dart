import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/ui/editors/account_editor.dart';
import 'package:aurum/ui/pages/more/more.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Accounts extends StatelessWidget {
  const Accounts({super.key});

  @override
  Widget build(BuildContext context) => PageBase(
        builtInScrollView: false,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Accounts'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.create),
            onPressed: () => Navigator.of(context).push(CupertinoModalPopupRoute(builder: (context) => const AccountEditor())),
          ),
        ),
        child: AurumCollectionBuilder(
          collection: AurumDatabase.accounts,
          onEmpty: const EmptyListPlaceholder(
            icon: Icons.wallet_outlined,
            title: 'No accounts',
            messageBeforeIcon: 'You can add an account by tapping the ',
            messageAfterIcon: ' button.',
          ),
          builder: (context, accounts) => SingleChildScrollView(
            child: CupertinoListSection.insetGrouped(
              hasLeading: true,
              children: accounts.map(_ItemView.forItem).toList(),
            ),
          ),
        ),
      );
}

class _ItemView extends StatelessWidget {
  final Account account;

  const _ItemView.forItem(this.account);

  @override
  Widget build(BuildContext context) => CupertinoListTile(
        title: Text(account.name),
        leading: SquareIcon(background: account.color, child: Icon(account.icon)),
        leadingSize: 36,
        trailing: const CupertinoListTileChevron(),
        onTap: () =>
            Navigator.of(context).push(CupertinoModalPopupRoute(builder: (context) => AccountEditor(account: account))),
      );
}
