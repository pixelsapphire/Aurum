import 'dart:math';

T max<T extends Comparable<T>>(T a, T b) => a.compareTo(b) > 0 ? a : b;

T min<T extends Comparable<T>>(T a, T b) => a.compareTo(b) < 0 ? a : b;

double sum<E extends num>(Iterable<E> values) => values.fold(0, (a, b) => a + b);

double mean<E extends num>(Iterable<E> values) => sum(values) / values.length;

double median<E extends num>(Iterable<E> values) {
  final List<E> sorted = List<E>.from(values)..sort();
  if (sorted.length.isEven) {
    return (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;
  } else {
    return sorted[sorted.length ~/ 2].toDouble();
  }
}

int? chartInterval({required double range, required double preferredTicks}) {
  if (range == 0) return null;
  final List<double> intervals = [1, 2.5, 5, 10, 25, 50];
  final int power = pow(10, (log(range) / ln10).floor() - 1).round();
  double bestCandidate = 0, bestDelta = double.infinity;
  for (final interval in intervals) {
    final double candidate = interval * power;
    final double ticks = range / candidate;
    final double delta = (ticks - preferredTicks).abs();
    if (delta < bestDelta) {
      bestCandidate = candidate;
      bestDelta = delta;
    }
  }
  return bestCandidate.round();
}
