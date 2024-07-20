import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/editors/editor_base.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/ui/widgets/dialogs/modal_icon_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/ui/widgets/list_item.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

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

  Widget _parentTile(BuildContext context, AsyncSnapshot<Category> snapshot) => CupertinoListItem.custom(
        label: 'Parent',
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

  Widget _nameTile(BuildContext context) => CupertinoListItem.basic(
        label: 'Name',
        value: _name,
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

  Widget _iconTile(BuildContext context) => CupertinoListItem.custom(
        label: 'Icon',
        trailing: SquareIcon(background: _color, child: Icon(_icon)),
        chevron: true,
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalIconInput(
            title: const Text('Category icon'),
            icons: Category.supportedIcons,
            initialIcon: _icon,
            initialColor: _color,
            onSubmit: (icon, color) => setState(() {
              _icon = icon;
              _color = color;
            }),
          ),
        ),
      );

  Widget _analyzedTile(BuildContext context) => CupertinoListItem.custom(
        label: 'Analyzed',
        trailing: CupertinoSwitch(
          activeColor: CupertinoColors.systemGreen,
          value: _analyzed,
          onChanged: (value) => setState(() => _analyzed = value),
        ),
      );

  List<Widget> _editActions(BuildContext context) => [
        CupertinoListItem.icon(
          label: 'Add subcategory',
          icon: CupertinoIcons.create,
          onTap: () => Navigator.of(context)
              .push(CupertinoModalPopupRoute(builder: (context) => CategoryEditor(parent: widget.category!))),
        ),
        CupertinoListItem.icon(
          label: 'Delete category',
          icon: CupertinoIcons.delete,
          isDestructiveAction: true,
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
