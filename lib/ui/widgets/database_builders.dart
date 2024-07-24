import 'package:aurum/data/collections/collection.dart';
import 'package:aurum/data/database.dart';
import 'package:flutter/cupertino.dart';

class AurumCollectionBuilder<T> extends StatelessWidget {
  final AurumCollection<T> collection;
  final Widget Function(BuildContext context, List<T> data) builder;
  final Widget onNull, onEmpty;
  final Widget Function(dynamic error)? onError;

  const AurumCollectionBuilder({
    super.key,
    required this.collection,
    required this.builder,
    this.onNull = const SizedBox(),
    this.onEmpty = const SizedBox(),
    this.onError,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: collection,
        builder: (context, result, _) {
          final onError = this.onError ?? (error) => Center(child: Text('Error: $error'));
          if (result == null) return onNull;
          if (result.hasError) return onError(result.error);
          if (result.data?.isEmpty ?? false) return onEmpty;
          return builder(context, result.data!);
        },
      );
}

class AurumDerivedValueBuilder<T> extends StatelessWidget {
  final AurumDerivedValue<T> value;
  final Widget Function(BuildContext context, T? data) builder;

  const AurumDerivedValueBuilder({super.key, required this.value, required this.builder});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: value,
        builder: (context, value, _) => builder(context, value),
      );
}

class AurumFutureBuilder<T> extends StatelessWidget {
  final Future<T> Function() future;
  final Widget Function(BuildContext context, AsyncSnapshot<T> snapshot) builder;
  final ValueNotifier notifier;

  const AurumFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, _, __) => FutureBuilder(
          future: future(),
          builder: builder,
        ),
      );
}
