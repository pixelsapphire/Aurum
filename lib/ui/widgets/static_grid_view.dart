import 'package:flutter/widgets.dart';

class StaticGridView extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;
  final CrossAxisAlignment horizontalAlignment, verticalAlignment;

  const StaticGridView({
    super.key,
    this.crossAxisCount = 1,
    this.horizontalAlignment = CrossAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final int nRows = (children.length / crossAxisCount).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontalAlignment,
      children: List.generate(
        nRows,
        (row) => Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: verticalAlignment,
          children: List.generate(
            row < nRows - 1 ? crossAxisCount : (children.length - 1) % crossAxisCount + 1,
            (col) => children[row * crossAxisCount + col],
          ),
        ),
      ),
    );
  }
}
