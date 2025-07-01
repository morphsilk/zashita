import 'package:flutter/foundation.dart';
import 'account.dart';
import 'financial_goal.dart';

enum UserRole {
  admin,
  adult,
  child,
}

class User {
  final String name;
  final String email;
  final String password;
  final String familyId;
  final UserRole role;
  final String? token;
  List<Account> accounts;
  List<FinancialGoal> goals;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.familyId,
    required this.role,
    this.accounts = const [],
    this.goals = const [],
    this.token,
  }) {
    accounts = List.from(accounts);
    goals = List.from(goals);
  }

  User copyWith({
    String? name,
    String? email,
    String? password,
    String? familyId,
    UserRole? role,
    String? token,
    List<Account>? accounts,
    List<FinancialGoal>? goals,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      familyId: familyId ?? this.familyId,
      role: role ?? this.role,
      token: token ?? this.token,
      accounts: accounts ?? List.from(this.accounts),
      goals: goals ?? List.from(this.goals),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'familyId': familyId,
    'role': role.toString().split('.').last,
    'accounts': accounts.map((account) => account.toJson()).toList(),
    'goals': goals.map((goal) => goal.toJson()).toList(),
    'token': token,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
    familyId: json['familyId'] ?? '',
    role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == (json['role'] ?? 'adult'),
      orElse: () => UserRole.adult,
    ),
    token: json['token'],
  )..accounts = (json['accounts'] as List?)
      ?.map((a) => Account.fromJson(a))
      .toList() ?? []
    ..goals = (json['goals'] as List?)
        ?.map((g) => FinancialGoal.fromJson(g))
        .toList() ?? [];
}