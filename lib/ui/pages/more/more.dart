import 'package:aurum/ui/pages/more/accounts.dart';
import 'package:aurum/ui/pages/more/categories.dart';
import 'package:aurum/ui/pages/more/console.dart';
import 'package:aurum/ui/pages/more/counterparties.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class More extends StatelessWidget {
  const More({super.key});

  @override
  Widget build(BuildContext context) => PageBase(
        navigationBar: const CupertinoNavigationBar(middle: Text('More')),
        child: CupertinoListSection.insetGrouped(
          hasLeading: true,
          children: [
            CupertinoListTile(
              title: const Text('Accounts'),
              leading: const SquareIcon(background: CupertinoColors.systemBlue, child: Icon(Icons.wallet_outlined)),
              leadingSize: 36,
              trailing: const CupertinoListTileChevron(),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const Accounts())),
            ),
            CupertinoListTile(
              title: const Text('Categories'),
              leading: const SquareIcon(background: CupertinoColors.systemIndigo, child: Icon(Icons.category_outlined)),
              leadingSize: 36,
              trailing: const CupertinoListTileChevron(),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const Categories())),
            ),
            CupertinoListTile(
              title: const Text('Counterparties'),
              leading: const SquareIcon(background: CupertinoColors.systemCyan, child: Icon(Icons.person_outlined)),
              leadingSize: 36,
              trailing: const CupertinoListTileChevron(),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const Counterparties())),
            ),
            CupertinoListTile(
              title: const Text('Database console'),
              leading: const SquareIcon(background: CupertinoColors.systemGrey, child: Icon(Icons.code)),
              leadingSize: 36,
              trailing: const CupertinoListTileChevron(),
              onTap: () => Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const Console())),
            ),
          ],
        ),
      );
}
