import 'package:flutter/material.dart';

enum RecordType {
  expense(Icons.arrow_upward),
  income(Icons.arrow_downward),
  ownTransfer(Icons.compare_arrows);

  final IconData icon;

  const RecordType(this.icon);
}

class RecordFragment {
  // id is nullable because it's not known when a new fragment is created and is only assigned by the database when inserted
  final int? id;
  final int recordId, categoryId;
  final double amount;

  RecordFragment(this.id, this.recordId, this.categoryId, this.amount);

  RecordFragment.empty({this.recordId = -1})
      : id = null,
        categoryId = -1,
        amount = 0;

  RecordFragment.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        recordId = map['record_id'],
        categoryId = map['category_id'],
        amount = map['amount'];

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'record_id': recordId,
        'category_id': categoryId,
        'amount': amount,
      };

  RecordFragment copyWith({int? recordId, int? categoryId, double? amount}) =>
      RecordFragment(id, recordId ?? this.recordId, categoryId ?? this.categoryId, amount ?? this.amount);

  bool get isNotEmpty => recordId != -1 && categoryId != -1;
}

class Record {
  // id is nullable because it's not known when a new record is created and is only assigned by the database when inserted
  final int? id, fromCounterpartyId, toCounterpartyId, transactionId;
  final String? fromAccountName, toAccountName;
  final DateTime time;
  final String? note;
  final List<RecordFragment> fragments;

  Record(
    this.id,
    this.fromAccountName,
    this.fromCounterpartyId,
    this.toAccountName,
    this.toCounterpartyId,
    this.time,
    this.transactionId,
    this.note,
    this.fragments,
  );

  RecordType get type {
    if (fromAccountName != null && toAccountName != null) {
      return RecordType.ownTransfer;
    } else if (fromAccountName != null) {
      return RecordType.expense;
    } else {
      return RecordType.income;
    }
  }

  Record.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        fromAccountName = map['payer_account_name'],
        fromCounterpartyId = map['payer_counterparty_id'],
        toAccountName = map['payee_account_name'],
        toCounterpartyId = map['payee_counterparty_id'],
        time = DateTime.parse(map['time']),
        transactionId = map['transaction_id'],
        note = map['note'],
        fragments = [];

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'payer_account_name': fromAccountName,
        'payer_counterparty_id': fromCounterpartyId,
        'payee_account_name': toAccountName,
        'payee_counterparty_id': toCounterpartyId,
        'time': time.toIso8601String(),
        'transaction_id': transactionId,
        'note': note,
      };

  Record withTransactionId(int? transactionId) =>
      Record(id, fromAccountName, fromCounterpartyId, toAccountName, toCounterpartyId, time, transactionId, note, fragments);

  int? get counterpartyId => fromCounterpartyId ?? toCounterpartyId;

  Set<String> get accountNames => {if (fromAccountName != null) fromAccountName!, if (toAccountName != null) toAccountName!};

  bool get isExpense => type == RecordType.expense;

  bool get isIncome => type == RecordType.income;

  bool get isOwnTransfer => type == RecordType.ownTransfer;
}
