import 'dart:math';
import 'package:aurum/data/database.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:flutter/cupertino.dart';

class CategoryIcons extends StatelessWidget {
  final Set<int> categoryIds;

  const CategoryIcons({super.key, required this.categoryIds});

  @override
  Widget build(BuildContext context) {
    if (categoryIds.isEmpty) return const SizedBox(width: 32, height: 32);
    final int crossAxisCount = sqrt(categoryIds.length).ceil();
    return SizedBox(
      width: 32,
      height: 32,
      child: Align(
        alignment: Alignment.center,
        child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            children: categoryIds
                .map((categoryId) => AurumFutureBuilder(
                      notifier: AurumDatabase.categories,
                      future: () => AurumDatabase.categories.getById(categoryId),
                      builder: (context, snapshot) => !snapshot.hasData
                          ? const SizedBox()
                          : SquareIcon(
                              background: snapshot.data!.color,
                              borderRadius: 8.0 / crossAxisCount,
                              padding: 4.0 / crossAxisCount,
                              child: Icon(snapshot.data!.icon, color: CupertinoColors.white, size: 24.0 / crossAxisCount),
                            ),
                    ))
                .toList()),
      ),
    );
  }
}
