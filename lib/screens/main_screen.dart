import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/income_category.dart';
import '../models/expense_category.dart';
import '../models/category.dart';
import '../models/financial_goal.dart';
import '../models/user.dart';
import '../models/family.dart';
import 'add_account_screen.dart';
import 'analytics_screen.dart';
import 'goals_budget_screen.dart';
import 'family_management_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final List<Account> accounts;
  final List<FinancialGoal> goals;
  final void Function(Account)? onAddAccount;
  final Family family; // Добавляем family
  final User currentUser; // Добавляем currentUser
  final VoidCallback? onManageFamily;

  MainScreen({
    required this.accounts,
    required this.goals,
    required this.onAddAccount,
    required this.family,
    required this.currentUser,
    this.onManageFamily,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double get totalBalance {
    return widget.accounts
        .where((account) => account.currency == 'RUB')
        .fold(0, (sum, account) => sum + account.balance);
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Добавить счёт'),
              onTap: () {
                Navigator.pop(context);
                _addAccount(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_upward),
              title: Text('Добавить доход'),
              onTap: () {
                Navigator.pop(context);
                _showTransactionDialog(context, true);
              },
            ),
            ListTile(
              leading: Icon(Icons.arrow_downward),
              title: Text('Добавить расход'),
              onTap: () {
                Navigator.pop(context);
                _showTransactionDialog(context, false);
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Перевод между счетами'),
              onTap: () {
                Navigator.pop(context);
                _showTransferDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addAccount(BuildContext context) async {
    final newAccount = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAccountScreen()),
    );
    if (newAccount != null) {
      print('Новый счёт из AddAccountScreen: ${newAccount.name}');
      if (widget.onAddAccount != null) {
        widget.onAddAccount!(newAccount);
      }
      print('Список счетов в MainScreen после добавления: ${widget.accounts.length}');
    }
  }

  void _showTransactionDialog(BuildContext context, bool isIncome) {
    Account? selectedAccount;
    double amount = 0.0;
    Category? selectedCategory;
    String? selectedSubcategory;
    bool showCustomCategoryInput = false;
    String? customCategory;
    bool showCustomSubcategoryInput = false;
    List<Account> availableAccounts = widget.accounts;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isIncome ? 'Добавить доход' : 'Добавить расход'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Account>(
                  decoration: InputDecoration(labelText: 'Счёт'),
                  value: selectedAccount,
                  items: availableAccounts.map((account) {
                    return DropdownMenuItem<Account>(
                      value: account,
                      child: Text(account.name, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (value) => setDialogState(() => selectedAccount = value),
                  validator: (value) => value == null ? 'Выберите счёт' : null,
                ),
                DropdownButtonFormField<dynamic>(
                  decoration: InputDecoration(labelText: 'Категория (необязательно)'),
                  items: [
                    DropdownMenuItem<dynamic>(
                      value: null,
                      child: Text('Без категории', overflow: TextOverflow.ellipsis),
                    ),
                    ...(isIncome ? incomeCategories : expenseCategories).map((category) {
                      return DropdownMenuItem<dynamic>(
                        value: category,
                        child: Text(category.name, overflow: TextOverflow.ellipsis),
                      );
                    }),
                    if (isIncome) ...widget.goals.map((goal) => DropdownMenuItem<dynamic>(
                      value: 'На цель: ${goal.description}',
                      child: Text('На цель: ${goal.description}', overflow: TextOverflow.ellipsis),
                    )),
                    DropdownMenuItem<dynamic>(
                      value: 'custom',
                      child: Text('Добавить свою', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == 'custom') {
                        showCustomCategoryInput = true;
                        selectedCategory = null;
                        customCategory = null;
                        selectedSubcategory = null;
                        showCustomSubcategoryInput = false;
                        availableAccounts = widget.accounts;
                      } else if (value is String && value.startsWith('На цель: ')) {
                        showCustomCategoryInput = false;
                        selectedCategory = null;
                        customCategory = value;
                        selectedSubcategory = null;
                        showCustomSubcategoryInput = false;
                        final goalDescription = value.replaceFirst('На цель: ', '');
                        final goal = widget.goals.firstWhere((g) => g.description == goalDescription);
                        availableAccounts = widget.accounts.where((acc) => acc.name == goal.accountName).toList();
                        selectedAccount = availableAccounts.isNotEmpty ? availableAccounts.first : null;
                      } else {
                        showCustomCategoryInput = false;
                        selectedCategory = value;
                        customCategory = null;
                        selectedSubcategory = null;
                        showCustomSubcategoryInput = false;
                        availableAccounts = widget.accounts;
                      }
                    });
                  },
                ),
                if (showCustomCategoryInput) ...[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Своя категория'),
                    onChanged: (value) => setDialogState(() {
                      customCategory = value.isEmpty ? null : value;
                      if (value.isNotEmpty) showCustomSubcategoryInput = true;
                    }),
                  ),
                  if (showCustomSubcategoryInput)
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Своя подкатегория (необязательно)'),
                      onChanged: (value) => setDialogState(() => selectedSubcategory = value.isEmpty ? null : value),
                    ),
                ],
                if (selectedCategory != null)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Подкатегория (необязательно)'),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Без подкатегории', overflow: TextOverflow.ellipsis),
                      ),
                      ...selectedCategory!.subcategories.map((subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory, overflow: TextOverflow.ellipsis),
                        );
                      }),
                      DropdownMenuItem<String>(
                        value: 'custom',
                        child: Text('Добавить свою', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == 'custom') {
                          showCustomSubcategoryInput = true;
                          selectedSubcategory = null;
                        } else {
                          showCustomSubcategoryInput = false;
                          selectedSubcategory = value;
                        }
                      });
                    },
                  ),
                if (showCustomSubcategoryInput && !showCustomCategoryInput)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Своя подкатегория'),
                    onChanged: (value) => setDialogState(() => selectedSubcategory = value.isEmpty ? null : value),
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Сумма'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
                  validator: (value) =>
                  value!.isEmpty || double.tryParse(value) == null ? 'Введите сумму' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedAccount != null && amount > 0) {
                  if (!isIncome && selectedAccount!.balance < amount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Недостаточно средств')),
                    );
                    return;
                  }
                  setState(() {
                    selectedAccount!.registerTransaction(
                      isIncome ? amount : -amount,
                      category: customCategory ?? selectedCategory?.name,
                      subcategory: selectedSubcategory,
                    );
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Неверные данные')),
                  );
                }
              },
              child: Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    Account? fromAccount;
    Account? toAccount;
    double amount = 0.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Перевод между счетами'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Account>(
              decoration: InputDecoration(labelText: 'Откуда'),
              items: widget.accounts.map((account) {
                return DropdownMenuItem<Account>(
                  value: account,
                  child: Text(account.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) => fromAccount = value,
              validator: (value) => value == null ? 'Выберите счёт' : null,
            ),
            DropdownButtonFormField<Account>(
              decoration: InputDecoration(labelText: 'Куда'),
              items: widget.accounts.map((account) {
                return DropdownMenuItem<Account>(
                  value: account,
                  child: Text(account.name, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) => toAccount = value,
              validator: (value) => value == null ? 'Выберите счёт' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Сумма'),
              keyboardType: TextInputType.number,
              onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
              validator: (value) =>
              value!.isEmpty || double.tryParse(value) == null ? 'Введите сумму' : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (fromAccount != null &&
                  toAccount != null &&
                  fromAccount != toAccount &&
                  amount > 0 &&
                  fromAccount!.balance >= amount) {
                setState(() {
                  fromAccount!.registerTransaction(-amount, transferTo: toAccount!.name);
                  toAccount!.registerTransaction(amount, transferTo: fromAccount!.name);
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      fromAccount == toAccount
                          ? 'Нельзя перевести на тот же счёт'
                          : 'Недостаточно средств или неверные данные',
                    ),
                  ),
                );
              }
            },
            child: Text('Перевести'),
          ),
        ],
      ),
    );
  }

  void _showProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          family: widget.family,
          currentUser: widget.currentUser,
          accounts: widget.accounts,
          onRemoveFamilyMember: (user) {
            setState(() {
              widget.family.users.removeWhere((u) => u.email == user.email);
            });
          },
          onUpdateRole: (user, newRole) {
            setState(() {
              final index = widget.family.users.indexWhere((u) => u.email == user.email);
              if (index != -1) {
                widget.family.users[index] = user.copyWith(role: newRole);
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расходы семьи'),
        actions: [
          if (widget.currentUser.role == UserRole.admin)
            IconButton(
              icon: Icon(Icons.group),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FamilyManagementScreen(
                      familyUsers: widget.family.users,
                      onAddFamilyMember: (newUser) {
                        setState(() {
                          widget.family.users.add(newUser);
                        });
                      },
                      onRemoveFamilyMember: (user) {
                        setState(() {
                          widget.family.users.removeWhere((u) => u.email == user.email);
                        });
                      },
                      onUpdateRole: (user, newRole) {
                        setState(() {
                          final index = widget.family.users.indexWhere((u) => u.email == user.email);
                          if (index != -1) {
                            widget.family.users[index] = user.copyWith(role: newRole);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
              tooltip: 'Управление семьёй',
            ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => _showProfile(context),
            tooltip: 'Профиль',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Баланс: ${totalBalance.toStringAsFixed(2)} руб.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                return ListTile(
                  title: Text(account.name),
                  subtitle: Text(account.type),
                  trailing: Text('${account.balance.toStringAsFixed(2)} ${account.currency}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.onAddAccount != null
          ? FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}