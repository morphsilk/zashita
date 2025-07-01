import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/financial_goal.dart';

class GoalsBudgetScreen extends StatefulWidget {
  final List<Account> accounts;
  final List<FinancialGoal> goals;

  GoalsBudgetScreen({required this.accounts, required this.goals});

  @override
  _GoalsBudgetScreenState createState() => _GoalsBudgetScreenState();
}

class _GoalsBudgetScreenState extends State<GoalsBudgetScreen> {
  String? _selectedAccountName;

  @override
  void initState() {
    super.initState();
    _updateGoalsProgress();
  }

  void _updateGoalsProgress() {
    for (var goal in widget.goals) {
      final account = widget.accounts.firstWhere((acc) => acc.name == goal.accountName);
      goal.totalAmount = account.history
          .where((history) => history.category == goal.goalCategory && history.amount > 0)
          .fold(0.0, (sum, history) => sum + history.amount);
    }
  }

  void _addGoal() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _GoalDialog(accounts: widget.accounts),
    );
    if (result != null) {
      setState(() {
        final newGoal = FinancialGoal(
          description: result['description'],
          requiredAmount: result['requiredAmount'],
          deadlineDate: result['deadlineDate'],
          accountName: result['accountName'],
          goalCategory: 'На цель: ${result['description']}',
        );
        widget.goals.add(newGoal);
        _updateGoalsProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Цели и бюджет'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите счёт:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedAccountName,
              hint: Text('Все счета'),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('Все счета'),
                ),
                ...widget.accounts.map((account) => DropdownMenuItem<String>(
                  value: account.name,
                  child: Text(account.name, overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAccountName = value;
                  _updateGoalsProgress();
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Цели:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.goals.length,
                itemBuilder: (context, index) {
                  final goal = widget.goals[index];
                  if (_selectedAccountName != null && goal.accountName != _selectedAccountName) {
                    return SizedBox.shrink();
                  }
                  final isCompleted = goal.checkCompletion();
                  final remaining = goal.requiredAmount - goal.totalAmount;
                  return ListTile(
                    title: Text(
                      goal.description,
                      style: TextStyle(
                        color: isCompleted ? Colors.green : null,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Накоплено: ${goal.totalAmount.toStringAsFixed(2)} руб.\n'
                          'Осталось: ${remaining > 0 ? remaining.toStringAsFixed(2) : "0.00"} руб.\n'
                          'Срок: ${goal.deadlineDate.toString().substring(0, 10)}',
                    ),
                    trailing: Icon(
                      isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: isCompleted ? Colors.green : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        child: Icon(Icons.add),
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  final List<Account> accounts;

  _GoalDialog({required this.accounts});

  @override
  __GoalDialogState createState() => __GoalDialogState();
}

class __GoalDialogState extends State<_GoalDialog> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _deadlineDate = DateTime.now().add(Duration(days: 30));
  String? _accountName = null; // Начальное значение null, но счёт обязателен

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _accountName = widget.accounts.first.name; // Устанавливаем первый счёт по умолчанию
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Новая цель'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Описание цели'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Требуемая сумма (руб.)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text('Срок: ${_deadlineDate.toString().substring(0, 10)}'),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadlineDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365 * 10)),
                );
                if (picked != null) setState(() => _deadlineDate = picked);
              },
              child: Text('Выбрать дату'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _accountName,
              decoration: InputDecoration(labelText: 'Счёт'),
              items: widget.accounts.map((account) => DropdownMenuItem<String>(
                value: account.name,
                child: Text(account.name, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (value) => setState(() => _accountName = value),
              validator: (value) => value == null ? 'Выберите счёт' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final description = _descriptionController.text;
            final requiredAmount = double.tryParse(_amountController.text) ?? 0.0;
            final accountName = _accountName;
            if (description.isNotEmpty && requiredAmount > 0 && accountName != null) {
              Navigator.pop(context, {
                'description': description,
                'requiredAmount': requiredAmount,
                'deadlineDate': _deadlineDate,
                'accountName': accountName,
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Заполните все поля')),
              );
            }
          },
          child: Text('Добавить'),
        ),
      ],
    );
  }
}