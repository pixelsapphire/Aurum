import 'dart:async';
import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/categories_service.dart';
import 'package:aurum/data/services/counterparties_service.dart';
import 'package:aurum/data/services/records_service.dart';
import 'package:aurum/ui/editors/editor_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/ui/widgets/dialogs/modal_datetime_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_money_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/ui/widgets/future_or_builder.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/pointer.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

class RecordFragmentSection extends StatelessWidget {
  final RecordFragment fragment;
  final Category? cachedCategory;
  final MoneyInputSign sign;
  final void Function(Category) onCategoryChanged;
  final void Function(double) onAmountChanged;
  final void Function()? onRemove;

  const RecordFragmentSection({
    super.key,
    required this.fragment,
    this.cachedCategory,
    required this.sign,
    required this.onCategoryChanged,
    required this.onAmountChanged,
    this.onRemove,
  });

  Widget _categoryTile(BuildContext context) {
    final GlobalKey selectionKey = GlobalKey();
    return AurumCollectionBuilder(
      collection: AurumDatabase.categories,
      onEmpty: const CupertinoListTile(title: Text('Category')),
      builder: (context, categories) => CupertinoListTile(
        title: const Text('Category'),
        trailing: Row(
          key: selectionKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FutureOrBuilder<Category>(
                future: cachedCategory ?? AurumDatabase.categories.getById(fragment.categoryId),
                builder: (context, snapshot) => Text(
                  snapshot.hasData ? snapshot.data!.name : 'Select category',
                  style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                ),
              ),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showPullDownMenu(
          context: context,
          items: categories
              .sorted(CategoriesService.compareNames)
              .map((category) => PullDownMenuItem(
                    title: category.name,
                    subtitle: CategoriesService.getParentPath(category, categories, separator: ' / ')
                        .op((path) => path.isNotEmpty ? 'in $path' : null),
                    icon: category.icon,
                    onTap: () => onCategoryChanged(category),
                  ))
              .toList(),
          position: (selectionKey.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(0, 8),
          scrollController: ScrollController(),
        ),
      ),
    );
  }

  Widget _amountTile(BuildContext context) => CupertinoListTile(
        title: const Text('Amount'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '${fragment.amount.toStringAsFixed(2)} PLN',
                style: TextStyle(color: AurumColors.foregroundSecondary(context)),
              ),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalMoneyInput(
            title: const Text('Amount'),
            sign: sign,
            initialValue: fragment.amount,
            onSubmit: onAmountChanged,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => CupertinoListSection.insetGrouped(
        hasLeading: true,
        header: onRemove == null
            ? null
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 2),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      color: AurumColors.backgroundSecondary(context),
                      child: Icon(CupertinoIcons.clear, size: 16, color: AurumColors.foregroundSecondary(context)),
                    ),
                  ),
                ),
              ),
        children: [_categoryTile(context), _amountTile(context)],
      );
}

class RecordEditor extends StatefulWidget {
  final Record? record;

  const RecordEditor({super.key, this.record});

  @override
  State<RecordEditor> createState() => _RecordEditorState();
}

class _RecordEditorState extends State<RecordEditor> {
  bool _changed = false;
  RecordType _type = RecordType.expense;
  Pointer<String> _fromAccountName = Pointer(''), _toAccountName = Pointer('');
  late final Pointer<FutureOr<Counterparty?>> _fromCounterparty, _toCounterparty;
  final Pointer<bool> _fromCounterpartySelected = Pointer(false), _toCounterpartySelected = Pointer(false);
  DateTime _time = DateTime.now();
  String _note = '';
  final List<RecordFragment> _fragments = [];
  final Map<int, Category> _categoryCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _type = widget.record!.type;
      _fromAccountName = Pointer(widget.record!.fromAccountName ?? '');
      _toAccountName = Pointer(widget.record!.toAccountName ?? '');
      _fromCounterpartySelected.value = widget.record!.fromCounterpartyId != null;
      _toCounterpartySelected.value = widget.record!.toCounterpartyId != null;
      _time = widget.record!.time;
      _note = widget.record!.note ?? '';
      _fragments.addAll(widget.record!.fragments);
    } else {
      _fragments.add(RecordFragment.empty());
    }
    _fromCounterparty = widget.record?.fromCounterpartyId?.op((id) => //
        Pointer(AurumDatabase.counterparties.getById(id))) ?? Pointer(Future.value(null));
    _toCounterparty = widget.record?.toCounterpartyId?.op((id) => //
        Pointer(AurumDatabase.counterparties.getById(id))) ?? Pointer(Future.value(null));
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _changed = true;
  }

  Widget _typeTile(BuildContext context) {
    const Map<RecordType, String> typeNames = {
      RecordType.expense: 'Expense',
      RecordType.income: 'Income',
      RecordType.ownTransfer: 'Own transfer',
    };
    final GlobalKey selectionKey = GlobalKey();
    return CupertinoListTile(
      title: const Text('Type'),
      trailing: Row(
        key: selectionKey,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(typeNames[_type]!, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
          ),
          const CupertinoListTileChevron(),
        ],
      ),
      onTap: () => showPullDownMenu(
        context: context,
        items: RecordType.values
            .map((type) => PullDownMenuItem(
                  title: typeNames[type]!,
                  icon: type.icon,
                  onTap: () => setState(() {
                    _type = type;
                    final int sign = type == RecordType.expense ? -1 : 1;
                    for (int i = 0; i < _fragments.length; ++i) {
                      _fragments[i] = _fragments[i].copyWith(amount: sign * _fragments[i].amount.abs());
                    }
                  }),
                ))
            .toList(),
        position: (selectionKey.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(0, 8),
        scrollController: ScrollController(),
      ),
    );
  }

  Widget _accountTile(BuildContext context, String title, Pointer<String> accountNamePtr) {
    final GlobalKey selectionKey = GlobalKey();
    return AurumCollectionBuilder(
      collection: AurumDatabase.accounts,
      onEmpty: CupertinoListTile(title: Text(title)),
      builder: (context, accounts) => CupertinoListTile(
        title: Text(title),
        trailing: Row(
          key: selectionKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                accountNamePtr.value.isEmpty ? 'Select account' : accountNamePtr.value,
                style: TextStyle(color: AurumColors.foregroundSecondary(context)),
              ),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showPullDownMenu(
          context: context,
          items: accounts
              .map((account) => PullDownMenuItem(
                    title: account.name,
                    iconWidget: FittedBox(
                      fit: BoxFit.contain,
                      child: SquareIcon(padding: 2, borderRadius: 6, background: account.color, child: Icon(account.icon)),
                    ),
                    onTap: () => setState(() => accountNamePtr.value = account.name),
                  ))
              .toList(),
          position: (selectionKey.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(0, 8),
          scrollController: ScrollController(),
        ),
      ),
    );
  }

  Widget _counterpartyTile(
    BuildContext context,
    String title,
    Pointer<FutureOr<Counterparty?>> counterpartyPtr,
    Pointer<bool> selectedPtr,
  ) {
    final GlobalKey selectionKey = GlobalKey();
    return AurumCollectionBuilder(
      collection: AurumDatabase.counterparties,
      onEmpty: CupertinoListTile(title: Text(title)),
      builder: (context, counterparties) => CupertinoListTile(
        title: Text(title),
        trailing: Row(
          key: selectionKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FutureOrBuilder<Counterparty?>(
                future: counterpartyPtr.valueOr(Future.value(null)),
                builder: (context, snapshot) => Text(
                  snapshot.hasData ? snapshot.data!.aliasOrName : 'Select counterparty',
                  style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                ),
              ),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showPullDownMenu(
          context: context,
          items: counterparties
              .sorted(CounterpartiesService.compareLexicographically)
              .map((counterparty) => PullDownMenuItem(
                    title: counterparty.aliasOrName,
                    subtitle: counterparty.alias == null ? null : counterparty.name,
                    icon: counterparty.type.icon,
                    onTap: () => setState(() {
                      counterpartyPtr.value = counterparty;
                      selectedPtr.value = true;
                    }),
                  ))
              .toList(),
          position: (selectionKey.currentContext!.findRenderObject() as RenderBox).bottomRight.translate(0, 8),
          scrollController: ScrollController(),
        ),
      ),
    );
  }

  Widget _dateTimeTile(BuildContext context) => CupertinoListTile(
        title: const Text('Time'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _time.toFullString(),
                style: TextStyle(color: AurumColors.foregroundSecondary(context)),
              ),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          builder: (context) => ModalDateTimeInput(
            title: const Text('Time'),
            initialValue: _time,
            onSubmit: (time) => setState(() => _time = time),
          ),
        ),
      );

  Widget _noteTile(BuildContext context) => CupertinoListTile(
        title: const Text('Note'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_note, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Record note'),
            initialValue: _note,
            onSubmit: (value) => setState(() => _note = value),
          ),
        ),
      );

  Widget _editActions(BuildContext context) => CupertinoListSection.insetGrouped(
        hasLeading: false,
        children: [
          CupertinoListTile(
            title: const Text('Add category division'),
            trailing: Icon(CupertinoIcons.create, color: AurumColors.foregroundPrimary(context)),
            onTap: () => setState(() => _fragments.add(RecordFragment.empty())),
          ),
          if (widget.record != null) ...[
            CupertinoListTile(
              title: const Text('Duplicate record'),
              trailing: Icon(CupertinoIcons.plus_square_on_square, color: AurumColors.foregroundPrimary(context)),
              onTap: () => AurumDatabase.records
                  .insert(RecordsService.clone(widget.record!))
                  .then((_) => Navigator.of(context).pop(), onError: (error) => showDatabaseError(context, error)),
            ),
            if (widget.record!.transactionId != null)
              CupertinoListTile(
                title: const Text('Remove from transaction', style: TextStyle(color: CupertinoColors.systemRed)),
                trailing: const Icon(CupertinoIcons.link, color: CupertinoColors.systemRed),
                onTap: () => Navigator.of(context).push(
                  CupertinoModalPopupRoute(
                    builder: (context) => CupertinoActionSheet(
                      title: const Text('Remove from transaction?'),
                      message: const Text(
                          'Are you sure you want to remove this record from its transaction? The record itself will not be deleted.'),
                      actions: [
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () => AurumDatabase.records
                              .update(widget.record!, widget.record!.withTransactionId(null))
                              .then((_) => Navigator.of(context).popMany(2),
                                  onError: (error) => showDatabaseError(context, error)),
                          child: const Text('Remove from transaction'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            CupertinoListTile(
              title: const Text('Delete record', style: TextStyle(color: CupertinoColors.systemRed)),
              trailing: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
              onTap: () => Navigator.of(context).push(
                CupertinoModalPopupRoute(
                  builder: (context) => CupertinoActionSheet(
                    title: const Text('Delete record?'),
                    message:
                        const Text('Are you sure you want to delete this record? You will not be able to undo this action.'),
                    actions: [
                      CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        onPressed: () => AurumDatabase.records.delete(widget.record!).then(
                            (_) => Navigator.of(context).popMany(2),
                            onError: (error) => showDatabaseError(context, error)),
                        child: const Text('Delete record'),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );

  bool _duplicateCategory() {
    final Set<int> categoryIds = {};
    for (final fragment in _fragments) {
      if (!categoryIds.add(fragment.categoryId)) return true;
    }
    return false;
  }

  bool _errorMessage() {
    if ((_type == RecordType.expense && (_fromAccountName.value.isEmpty || !_toCounterpartySelected.value)) ||
        (_type == RecordType.income && (!_fromCounterpartySelected.value || _toAccountName.value.isEmpty))) {
      showErrorMessage(context, 'Account and counterparty must be selected.');
    } else if (_type == RecordType.ownTransfer && (_fromAccountName.value.isEmpty || _toAccountName.value.isEmpty)) {
      showErrorMessage(context, 'Accounts must be selected.');
    } else if (_fromCounterparty.isNull || _toCounterparty.isNull) {
      showErrorMessage(context, 'Counterparty must be selected.');
    } else if (_duplicateCategory()) {
      showErrorMessage(context, 'Record contains multiple divisions with the same category.');
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => NewItemSheet(
        confirmOnExit: _changed,
        title: Text(widget.record == null ? 'New record' : 'Edit record'),
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                _typeTile(context),
                if (_type == RecordType.expense) ...[
                  _accountTile(context, 'Account', _fromAccountName),
                  _counterpartyTile(context, 'Payee', _toCounterparty, _toCounterpartySelected),
                ],
                if (_type == RecordType.income) ...[
                  _counterpartyTile(context, 'Payer', _fromCounterparty, _fromCounterpartySelected),
                  _accountTile(context, 'Account', _toAccountName),
                ],
                if (_type == RecordType.ownTransfer) ...[
                  _accountTile(context, 'From account', _fromAccountName),
                  _accountTile(context, 'To account', _toAccountName),
                ],
                _dateTimeTile(context),
                _noteTile(context),
              ],
            ),
            for (int i = 0; i < _fragments.length; ++i)
              RecordFragmentSection(
                fragment: _fragments[i],
                sign: {
                  RecordType.expense: MoneyInputSign.negative,
                  RecordType.income: MoneyInputSign.positive,
                  RecordType.ownTransfer: MoneyInputSign.none,
                }[_type]!,
                cachedCategory: _categoryCache[i],
                onCategoryChanged: (category) => setState(() {
                  _fragments[i] = _fragments[i].copyWith(categoryId: category.id);
                  _categoryCache[i] = category;
                }),
                onAmountChanged: (amount) => setState(() => _fragments[i] = _fragments[i].copyWith(amount: amount)),
                onRemove: _fragments.length > 1 ? () => setState(() => _fragments.removeAt(i)) : null,
              ),
            _editActions(context),
          ],
        ),
        onSave: () async {
          if (_errorMessage()) return;
          final String? fromAccount = _type != RecordType.income ? _fromAccountName.value : null;
          final int? fromCounterparty = _type == RecordType.income ? (await _fromCounterparty.value)?.id : null;
          final String? toAccount = _type != RecordType.expense ? _toAccountName.value : null;
          final int? toCounterparty = _type == RecordType.expense ? (await _toCounterparty.value)?.id : null;
          final newRecord = Record(widget.record?.id, fromAccount, fromCounterparty, toAccount, toCounterparty, _time,
              widget.record?.transactionId, _note.nullIfEmpty(), _fragments);
          (widget.record == null
                  ? AurumDatabase.records.insert(newRecord)
                  : AurumDatabase.records.update(widget.record!, newRecord))
              .then((_) => Navigator.of(context).pop(), onError: (error) => showDatabaseError(context, error));
        },
      );
}
