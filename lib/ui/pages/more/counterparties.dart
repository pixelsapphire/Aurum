import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/data/services/counterparties_service.dart';
import 'package:aurum/ui/editors/counterparty_editor.dart';
import 'package:aurum/ui/pages/more/more.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Counterparties extends StatelessWidget {
  const Counterparties({super.key});

  @override
  Widget build(BuildContext context) => PageBase(
        builtInScrollView: false,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Counterparties'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.create),
            onPressed: () =>
                Navigator.of(context).push(CupertinoModalPopupRoute(builder: (context) => const CounterpartyEditor())),
          ),
        ),
        child: AurumCollectionBuilder(
          collection: AurumDatabase.counterparties,
          onEmpty: const EmptyListPlaceholder(
            icon: Icons.person_outlined,
            title: 'No counterparties',
            messageBeforeIcon: 'You can add an account by tapping the ',
            messageAfterIcon: ' button.',
          ),
          builder: (context, counterparties) {
            final private = counterparties.where((counterparty) => counterparty.type == CounterpartyType.private);
            final companies = counterparties.where((counterparty) => counterparty.type == CounterpartyType.company);
            final franchises = counterparties.where((counterparty) => counterparty.type == CounterpartyType.franchise);
            final other = counterparties.where((counterparty) => counterparty.type == CounterpartyType.other);
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (private.isNotEmpty)
                    CupertinoListSection.insetGrouped(
                      header: const Text('Private'),
                      hasLeading: false,
                      children: [...private.sorted(CounterpartiesService.compareLexicographically).map(_ItemView.forItem)],
                    ),
                  if (companies.isNotEmpty)
                    CupertinoListSection.insetGrouped(
                      header: const Text('Companies'),
                      hasLeading: false,
                      children: [...companies.sorted(CounterpartiesService.compareLexicographically).map(_ItemView.forItem)],
                    ),
                  if (franchises.isNotEmpty)
                    CupertinoListSection.insetGrouped(
                      header: const Text('Franchises'),
                      hasLeading: false,
                      children: [...franchises.sorted(CounterpartiesService.compareLexicographically).map(_ItemView.forItem)],
                    ),
                  if (other.isNotEmpty)
                    CupertinoListSection.insetGrouped(
                      header: const Text('Other'),
                      hasLeading: false,
                      children: [...other.sorted(CounterpartiesService.compareLexicographically).map(_ItemView.forItem)],
                    ),
                ],
              ),
            );
          },
        ),
      );
}

class _ItemView extends StatelessWidget {
  final Counterparty counterparty;

  const _ItemView.forItem(this.counterparty);

  @override
  Widget build(BuildContext context) => CupertinoListTile(
        title: Row(
          children: [
            Text(counterparty.alias ?? counterparty.name),
            if (counterparty.alias != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    ' (${counterparty.name})',
                    style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                  ),
                ),
              ),
          ],
        ),
        leadingSize: 36,
        trailing: const CupertinoListTileChevron(),
        onTap: () => Navigator.of(context)
            .push(CupertinoModalPopupRoute(builder: (context) => CounterpartyEditor(counterparty: counterparty))),
      );
}
