import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/util/extensions.dart';

class CounterpartiesService {
  CounterpartiesService._();

  static int compareLexicographically(Counterparty a, Counterparty b) =>
      (a.alias ?? a.name).compareLexicographically(b.alias ?? b.name);
}
