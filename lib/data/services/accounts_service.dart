import 'package:aurum/data/objects/account.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/records_service.dart';
import 'package:aurum/util/extensions.dart';

class AccountsService {
  AccountsService._();

  static double accountBalance(Account account, List<Record> records) => records
      .where((rec) => rec.fromAccountName == account.name || rec.toAccountName == account.name)
      .map((r) => (r.isOwnTransfer && r.fromAccountName == account.name ? -1 : 1) * RecordsService.totalAmount(r))
      .fold(account.initialBalance, (balance, recordChange) => balance + recordChange)
      .roundToPlaces(2);
}
