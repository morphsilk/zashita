// lib/models/account_history.dart
class AccountHistory {
  DateTime historyDate;
  double amount;
  String type;
  String? relatedAccount;
  String? category;
  String? subcategory;

  AccountHistory({
    required this.historyDate,
    required this.amount,
    required this.type,
    this.relatedAccount,
    this.category,
    this.subcategory,
  });

  Map<String, dynamic> toJson() => {
    'historyDate': historyDate.toIso8601String(),
    'amount': amount,
    'type': type,
    'relatedAccount': relatedAccount,
    'category': category,
    'subcategory': subcategory,
  };

  factory AccountHistory.fromJson(Map<String, dynamic> json) => AccountHistory(
    historyDate: DateTime.parse(json['historyDate']),
    amount: json['amount'],
    type: json['type'],
    relatedAccount: json['relatedAccount'],
    category: json['category'],
    subcategory: json['subcategory'],
  );
}