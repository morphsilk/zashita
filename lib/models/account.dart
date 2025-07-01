// lib/models/account.dart
import 'dart:math';
import 'account_history.dart';

class Account {
  String name;
  double balance;
  String _number;
  String type;
  String currency;
  String? category;
  List<AccountHistory> history;

  Account({
    required this.name,
    required this.balance,
    required this.type,
    required this.currency,
    this.category,
  })  : _number = 'ACC${Random().nextInt(10000).toString().padLeft(4, '0')}',
        history = [];

  void registerTransaction(double amount, {String? transferTo, String? category, String? subcategory}) {
    balance += amount;
    history.add(AccountHistory(
      historyDate: DateTime.now(),
      amount: amount,
      type: transferTo != null
          ? (amount > 0 ? 'Перевод от' : 'Перевод на')
          : (amount >= 0 ? 'Доход' : 'Расход'),
      relatedAccount: transferTo,
      category: category,
      subcategory: subcategory,
    ));
  }

  String get number => _number;

  Map<String, dynamic> toJson() => {
    'name': name,
    'balance': balance,
    'number': _number,
    'type': type,
    'currency': currency,
    'category': category,
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    name: json['name'],
    balance: json['balance'],
    type: json['type'],
    currency: json['currency'],
    category: json['category'],
  )
    .._number = json['number']
    ..history = (json['history'] as List)
        .map((h) => AccountHistory.fromJson(h))
        .toList();
}