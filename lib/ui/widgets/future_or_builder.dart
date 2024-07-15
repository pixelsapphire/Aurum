import 'dart:async';
import 'package:flutter/widgets.dart';

class FutureOrBuilder<T> extends StatelessWidget {
  final FutureOr<T>? futureOrValue;
  final T? initialData;
  final AsyncWidgetBuilder<T> builder;

  const FutureOrBuilder({
    super.key,
    FutureOr<T>? future,
    this.initialData,
    required this.builder,
  }) : futureOrValue = future;

  @override
  Widget build(BuildContext context) {
    final futureOrValue = this.futureOrValue;
    if (futureOrValue is T) {
      return builder(context, AsyncSnapshot.withData(ConnectionState.done, futureOrValue));
    } else {
      return FutureBuilder(future: futureOrValue, initialData: initialData, builder: builder);
    }
  }
}
