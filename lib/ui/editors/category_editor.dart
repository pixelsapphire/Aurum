import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/editors/editor_base.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/ui/widgets/dialogs/modal_icon_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryEditor extends StatefulWidget {
  final Category? category, parent;

  const CategoryEditor({super.key, this.category, this.parent});

  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  bool _changed = false;
  String _name = '';
  IconData? _icon;
  Color? _color;
  bool _analyzed = true;
  Future<Category>? _parent;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _name = widget.category!.name;
      _icon = widget.category!.icon;
      _color = widget.category!.color;
      _analyzed = widget.category!.analyzed;
      _parent = widget.category!.parentId?.op((id) => AurumDatabase.categories.getById(id));
    } else if (widget.parent != null) {
      _parent = Future.value(widget.parent!);
      _icon = widget.parent!.icon;
      _color = widget.parent!.color;
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _changed = true;
  }

  Widget _parentTile(BuildContext context, AsyncSnapshot<Category> snapshot) => CupertinoListTile(
        title: const Text('Parent'),
        trailing: snapshot.hasData
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SquareIcon(background: snapshot.data!.color, child: Icon(snapshot.data!.icon)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(snapshot.data!.name, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
                  ),
                ],
              )
            : const SizedBox(),
      );

  Widget _nameTile(BuildContext context) => CupertinoListTile(
        title: const Text('Name'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_name, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Category name'),
            initialValue: _name,
            onSubmit: (value) => setState(() => _name = value),
          ),
        ),
      );

  Widget _iconTile(BuildContext context) => CupertinoListTile(
        title: const Text('Icon'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: SquareIcon(background: _color, child: Icon(_icon)),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalIconInput(
            title: const Text('Category icon'),
            icons: const [
              Icons.bakery_dining_outlined,
              Icons.ramen_dining_outlined,
              Icons.cookie_outlined,
              Icons.coffee_outlined,
              Icons.emoji_food_beverage_outlined,
              Icons.shopping_bag_outlined,
              Icons.shopping_cart_outlined,
              Icons.shopping_cart_checkout_outlined,
              Icons.cottage_outlined,
              Icons.electric_bolt_outlined,
              Icons.devices_outlined,
              Icons.chair_outlined,
              Icons.propane_tank_outlined,
              Icons.handyman_outlined,
              Icons.emoji_transportation_outlined,
              Icons.directions_bus_outlined,
              Icons.local_taxi_outlined,
              Icons.electric_scooter_outlined,
              Icons.spa_outlined,
              Icons.medical_services_outlined,
              Icons.card_giftcard_outlined,
              Icons.attractions_outlined,
              Icons.school_outlined,
              Icons.attach_money_outlined,
              Icons.currency_exchange_outlined,
              Icons.assured_workload_outlined,
              Icons.percent_outlined,
              Icons.compare_arrows_outlined,
              Icons.language_outlined,
              Icons.cable_outlined,
              Icons.more_horiz_outlined,
            ],
            initialIcon: _icon,
            initialColor: _color,
            onSubmit: (icon, color) => setState(() {
              _icon = icon;
              _color = color;
            }),
          ),
        ),
      );

  Widget _analyzedTile(BuildContext context) => CupertinoListTile(
        title: const Text('Analyzed'),
        trailing: CupertinoSwitch(
          activeColor: CupertinoColors.systemGreen,
          value: _analyzed,
          onChanged: (value) => setState(() => _analyzed = value),
        ),
      );

  List<Widget> _editActions(BuildContext context) => [
        CupertinoListTile(
          title: const Text('Add subcategory'),
          trailing: Icon(CupertinoIcons.create, color: AurumColors.foregroundPrimary(context)),
          onTap: () => Navigator.of(context)
              .push(CupertinoModalPopupRoute(builder: (context) => CategoryEditor(parent: widget.category!))),
        ),
        CupertinoListTile(
          title: const Text('Delete category', style: TextStyle(color: CupertinoColors.systemRed)),
          trailing: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
          onTap: () => Navigator.of(context).push(
            CupertinoModalPopupRoute(
              builder: (context) => CupertinoActionSheet(
                title: Text('Delete ${widget.category!.name}?'),
                message: const Text(
                    'Are you sure you want to permanently delete this category? You will not be able to undo this action.'),
                actions: [
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () => AurumDatabase.categories
                        .delete(widget.category!)
                        .then((_) => Navigator.of(context).popMany(2), onError: (error) => showDatabaseError(context, error)),
                    child: const Text('Delete category'),
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
      ];

  bool _errorMessage() {
    if (_name.isEmpty) {
      showErrorMessage(context, 'Category name cannot be empty.');
    } else if (_icon == null) {
      showErrorMessage(context, 'An icon must be created.');
    } else if (_color == null) {
      showErrorMessage(context, 'The icon color has not been selected.');
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _parent,
        builder: (context, snapshot) => NewItemSheet(
          confirmOnExit: _changed,
          title: Text(widget.category == null ? 'New category' : 'Edit category'),
          child: Column(
            children: [
              CupertinoListSection.insetGrouped(
                hasLeading: false,
                children: [
                  if (_parent != null) _parentTile(context, snapshot),
                  _nameTile(context),
                  _iconTile(context),
                  _analyzedTile(context),
                ],
              ),
              if (widget.category != null)
                CupertinoListSection.insetGrouped(hasLeading: false, children: _editActions(context)),
            ],
          ),
          onSave: () {
            if (_errorMessage()) return;
            final newCategory = Category(null, snapshot.data?.id, _name, _icon!, _color!, _analyzed);
            (widget.category == null
                    ? AurumDatabase.categories.insert(newCategory)
                    : AurumDatabase.categories.update(widget.category!, newCategory))
                .then((_) => Navigator.of(context).pop(),
                    onError: (error) =>
                        showDatabaseError(context, error, duplicateMessage: 'An category with the same name already exists.'));
          },
        ),
      );
}
