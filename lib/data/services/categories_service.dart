import 'package:aurum/data/objects/category.dart';

class CategoriesService {
  CategoriesService._();

  static String getPath(Category category, List<Category> categories, {String separator = '\uffff'}) {
    final parent = categories.firstWhere((c) => c.id == category.parentId, orElse: () => category);
    return parent == category ? category.name : '${getPath(parent, categories)}$separator${category.name}';
  }

  static String getParentPath(Category category, List<Category> categories, {String separator = '\uffff'}) {
    final parent = categories.firstWhere((c) => c.id == category.parentId, orElse: () => category);
    return parent == category ? '' : getPath(parent, categories, separator: separator);
  }

  static Category getInfraCategory(Category category, List<Category> categories) {
    if (category.isInfraCategory) return category;
    return getInfraCategory(categories.firstWhere((c) => c.id == category.parentId), categories);
  }

  static bool isAnalyzed(Category category, List<Category> categories) =>
      category.analyzed &&
      (category.isInfraCategory || isAnalyzed(categories.firstWhere((c) => c.id == category.parentId), categories));

  static int compareNames(Category a, Category b) => a.name.compareTo(b.name);

  static int comparePaths(Category a, Category b, List<Category> categories) =>
      getPath(a, categories).compareTo(getPath(b, categories));
}

class CategoryPathComparator {
  final List<Category> categories;

  CategoryPathComparator(this.categories);

  int compare(Category a, Category b) => CategoriesService.comparePaths(a, b, categories);
}
