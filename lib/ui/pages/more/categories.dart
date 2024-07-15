import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/services/categories_service.dart';
import 'package:aurum/ui/editors/category_editor.dart';
import 'package:aurum/ui/pages/more/more.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) => PageBase(
        builtInScrollView: false,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Categories'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.create),
            onPressed: () => Navigator.of(context).push(CupertinoModalPopupRoute(builder: (context) => const CategoryEditor())),
          ),
        ),
        child: AurumCollectionBuilder(
          collection: AurumDatabase.categories,
          onEmpty: const EmptyListPlaceholder(
            icon: Icons.category_outlined,
            title: 'No categories',
            messageBeforeIcon: 'You can add a category by tapping the ',
            messageAfterIcon: ' button.',
          ),
          builder: (context, categories) => SingleChildScrollView(
            child: CupertinoListSection.insetGrouped(
              hasLeading: true,
              children: (categories..sort(CategoryPathComparator(categories).compare))
                  .map((category) => _ItemView.forItem(category, CategoriesService.getPath(category, categories)))
                  .toList(),
            ),
          ),
        ),
      );
}

class _ItemView extends StatelessWidget {
  final Category category;
  final String path;

  const _ItemView.forItem(this.category, this.path);

  @override
  Widget build(BuildContext context) {
    Iterable<String> pathComponents = path.split('\uffff').skipLast(1);
    if (pathComponents.length > 3) pathComponents = ['\ufffe', ...pathComponents.skip(pathComponents.length - 3)];
    return CupertinoListTile(
      title: Row(
        children: [
          for (String component in pathComponents)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: component != '\ufffe' ? 36 : 16,
                  child: Text(
                    textAlign: TextAlign.center,
                    component != '\ufffe' ? component : '...',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 4),
                  child: Text(
                    '/',
                    style: TextStyle(
                      color: AurumColors.foregroundSecondary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          Expanded(child: Text(category.name)),
        ],
      ),
      leading: SquareIcon(background: category.color, child: Icon(category.icon)),
      leadingSize: 36,
      trailing: const CupertinoListTileChevron(),
      onTap: () =>
          Navigator.of(context).push(CupertinoModalPopupRoute(builder: (context) => CategoryEditor(category: category))),
    );
  }
}
