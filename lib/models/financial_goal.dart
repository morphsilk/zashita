import 'package:flutter/foundation.dart';

class FinancialGoal {
  final String description;
  final double requiredAmount;
  double totalAmount;
  final DateTime deadlineDate;
  final String accountName;
  final String goalCategory;

  FinancialGoal({
    required this.description,
    required this.requiredAmount,
    this.totalAmount = 0.0,
    required this.deadlineDate,
    required this.accountName,
    required this.goalCategory,
  });

  bool checkCompletion() {
    return totalAmount >= requiredAmount;
  }

  Map<String, dynamic> toJson() => {
    'description': description,
    'requiredAmount': requiredAmount,
    'totalAmount': totalAmount,
    'deadlineDate': deadlineDate.toIso8601String(),
    'accountName': accountName,
    'goalCategory': goalCategory,
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
    description: json['description'],
    requiredAmount: json['requiredAmount'],
    totalAmount: json['totalAmount'] ?? 0.0,
    deadlineDate: DateTime.parse(json['deadlineDate']),
    accountName: json['accountName'],
    goalCategory: json['goalCategory'] ?? 'На цель: ${json['description']}',
  );
}