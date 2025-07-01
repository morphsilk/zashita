// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/account_history.dart';
import '../models/income_category.dart';
import '../models/expense_category.dart';

class HistoryScreen extends StatefulWidget {
  final List<Account> accounts;

  HistoryScreen({required this.accounts});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'Все';
  DateTime? _startDate;
  DateTime? _endDate;
  String? _filterAccount;
  String? _filterCategory;

  List<AccountHistory> get _allHistory {
    List<AccountHistory> history = [];
    for (var account in widget.accounts) {
      history.addAll(account.history.map((h) => AccountHistory(
        historyDate: h.historyDate,
        amount: h.amount,
        type: h.type,
        relatedAccount: h.relatedAccount,
        category: h.category,
        subcategory: h.subcategory,
      )));
    }
    history.sort((a, b) => b.historyDate.compareTo(a.historyDate)); // LIFO
    return history;
  }

  List<AccountHistory> get _filteredHistory {
    var filtered = _allHistory;
    if (_filterType != 'Все') {
      filtered = filtered.where((h) => h.type.contains(_filterType)).toList();
    }
    if (_startDate != null) {
      filtered = filtered.where((h) => h.historyDate.isAfter(_startDate!.subtract(Duration(seconds: 1)))).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((h) => h.historyDate.isBefore(_endDate!.add(Duration(days: 1)))).toList();
    }
    if (_filterAccount != null) {
      filtered = filtered.where((h) {
        final owningAccount = widget.accounts.firstWhere((a) => a.history.any((ah) => ah.historyDate == h.historyDate && ah.amount == h.amount && ah.type == h.type));
        return owningAccount.name == _filterAccount || h.relatedAccount == _filterAccount;
      }).toList();
    }
    if (_filterCategory != null) {
      filtered = filtered.where((h) => h.category == _filterCategory).toList();
    }
    return filtered;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История операций'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Все', child: Text('Все')),
              PopupMenuItem(value: 'Доход', child: Text('Доходы')),
              PopupMenuItem(value: 'Расход', child: Text('Расходы')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterAccount = value == 'Все' ? null : value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Все', child: Text('Все счета')),
              ...widget.accounts.map((account) => PopupMenuItem(value: account.name, child: Text(account.name))),
            ],
            icon: Icon(Icons.account_balance),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterCategory = value == 'Все' ? null : value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Все', child: Text('Все категории')),
              ...incomeCategories.map((category) => PopupMenuItem(value: category.name, child: Text(category.name))),
              ...expenseCategories.map((category) => PopupMenuItem(value: category.name, child: Text(category.name))),
              ..._allHistory
                  .where((h) => h.category != null &&
                  !incomeCategories.any((c) => c.name == h.category) &&
                  !expenseCategories.any((c) => c.name == h.category))
                  .map((h) => h.category!)
                  .toSet()
                  .map((category) => PopupMenuItem(value: category, child: Text(category))),
            ],
            icon: Icon(Icons.category),
          ),
        ],
      ),
      body: _allHistory.isEmpty
          ? Center(child: Text('Нет операций'))
          : Column(
        children: [
          if (_startDate != null || _endDate != null || _filterAccount != null || _filterCategory != null)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_startDate != null || _endDate != null)
                    Text(
                      'Фильтр по дате: ${_startDate?.toString().substring(0, 10) ?? 'Любая'} - ${_endDate?.toString().substring(0, 10) ?? 'Любая'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_filterAccount != null)
                    Text(
                      'Фильтр по счёту: $_filterAccount',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (_filterCategory != null)
                    Text(
                      'Фильтр по категории: $_filterCategory',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredHistory.length,
              itemBuilder: (context, index) {
                final history = _filteredHistory[index];
                return ListTile(
                  title: Text(
                    '${history.type}${history.relatedAccount != null ? ' ${history.relatedAccount}' : ''}: ${history.amount.toStringAsFixed(2)}',
                  ),
                  subtitle: Text(
                    '${history.historyDate.toString()}${history.category != null ? ' • ${history.category}${history.subcategory != null ? ': ${history.subcategory}' : ''}' : ''}',
                  ),
                  trailing: Icon(
                    history.amount > 0 || history.type.contains('Перевод от') ? Icons.arrow_upward : Icons.arrow_downward,
                    color: history.amount > 0 || history.type.contains('Перевод от') ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}