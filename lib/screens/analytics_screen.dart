// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/account.dart';
import '../models/account_history.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Account> accounts;

  AnalyticsScreen({required this.accounts});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Месяц';
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _showIncomeChart = false;
  String? _selectedCategory;
  String? _selectedAccountNumber; // Используем number вместо id
  int? _touchedIndex;

  final Map<String, IconData> _categoryIcons = {
    'Зарплата': Icons.attach_money,
    'Зарплата: Премия': Icons.star,
    'Зарплата: Основная': Icons.account_balance_wallet,
    'Инвестиции': Icons.trending_up,
    'Инвестиции: Дивиденды': Icons.pie_chart,
    'Подарки': Icons.card_giftcard,
    'Подарки: День рождения': Icons.cake,
    'Продукты': Icons.fastfood,
    'Продукты: Доставка еды': Icons.delivery_dining,
    'Продукты: Супермаркет': Icons.shopping_cart,
    'Жилье': Icons.home,
    'Жилье: Квартплата': Icons.receipt,
    'Жилье: Ремонт': Icons.build,
    'Транспорт': Icons.directions_car,
    'Транспорт: Общественный': Icons.directions_bus,
    'Транспорт: Такси': Icons.local_taxi,
    'Развлечения': Icons.movie,
    'Развлечения: Кино': Icons.local_movies,
    'Развлечения: Концерты': Icons.music_note,
    'Здоровье': Icons.local_hospital,
    'Здоровье: Лекарства': Icons.medical_services,
    'Здоровье: Врачи': Icons.person_search,
    'Прочее': Icons.category,
    'Прочее: Подписки': Icons.subscriptions,
    'Прочее: Пожертвования': Icons.volunteer_activism,
    'Без категории': Icons.help_outline,
    'Без подкатегории': Icons.help_outline,
  };

  Map<String, double> get _incomeByCategory {
    Map<String, double> result = {};
    for (var account in widget.accounts) {
      if (_selectedAccountNumber == null || account.number == _selectedAccountNumber) {
        for (var history in account.history) {
          if (history.amount > 0 &&
              history.historyDate.isAfter(_startDate.subtract(Duration(seconds: 1))) &&
              history.historyDate.isBefore(_endDate.add(Duration(days: 1)))) {
            final category = history.category ?? 'Без категории';
            result[category] = (result[category] ?? 0) + history.amount;
          }
        }
      }
    }
    return result;
  }

  Map<String, double> get _expensesByCategory {
    Map<String, double> result = {};
    for (var account in widget.accounts) {
      if (_selectedAccountNumber == null || account.number == _selectedAccountNumber) {
        for (var history in account.history) {
          if (history.amount < 0 &&
              history.historyDate.isAfter(_startDate.subtract(Duration(seconds: 1))) &&
              history.historyDate.isBefore(_endDate.add(Duration(days: 1)))) {
            final category = history.category ?? 'Без категории';
            result[category] = (result[category] ?? 0) + (-history.amount);
          }
        }
      }
    }
    return result;
  }

  Map<String, double> get _expensesBySubcategory {
    Map<String, double> result = {};
    if (_selectedCategory == null) return result;
    for (var account in widget.accounts) {
      if (_selectedAccountNumber == null || account.number == _selectedAccountNumber) {
        for (var history in account.history) {
          if (history.amount < 0 &&
              history.historyDate.isAfter(_startDate.subtract(Duration(seconds: 1))) &&
              history.historyDate.isBefore(_endDate.add(Duration(days: 1))) &&
              history.category == _selectedCategory) {
            final subcategory = history.subcategory ?? 'Без подкатегории';
            result[subcategory] = (result[subcategory] ?? 0) + (-history.amount);
          }
        }
      }
    }
    return result;
  }

  Map<String, double> get _averageExpenses {
    Map<String, double> result = {};
    final daysInPeriod = _endDate.difference(_startDate).inDays + 1;
    final monthsInPeriod = (daysInPeriod / 30).toDouble(); // Не округляем, используем дробное значение
    if (_selectedCategory != null) {
      for (var account in widget.accounts) {
        if (_selectedAccountNumber == null || account.number == _selectedAccountNumber) {
          for (var history in account.history) {
            if (history.amount < 0 &&
                history.historyDate.isAfter(_startDate.subtract(Duration(seconds: 1))) &&
                history.historyDate.isBefore(_endDate.add(Duration(days: 1))) &&
                history.category == _selectedCategory) {
              final key = history.subcategory ?? _selectedCategory!;
              result[key] = (result[key] ?? 0) + (-history.amount);
            }
          }
        }
      }
      result.forEach((key, value) {
        result[key] = daysInPeriod <= 31 ? value : value / monthsInPeriod; // Среднее за месяц
      });
    }
    return result;
  }

  double get _totalIncome => _incomeByCategory.values.fold(0, (sum, value) => sum + value);
  double get _totalExpenses => _expensesByCategory.values.fold(0, (sum, value) => sum + value);
  double get _totalSelectedExpenses => _expensesByCategory[_selectedCategory] ?? 0;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Пользовательский';
      });
    }
  }

  String get _periodDisplay {
    if (_selectedPeriod == 'Пользовательский') {
      return '${_startDate.toString().substring(0, 10)} - ${_endDate.toString().substring(0, 10)}';
    }
    return _selectedPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _showIncomeChart ? _incomeByCategory : (_selectedCategory != null ? _expensesBySubcategory : _expensesByCategory);
    final chartTitle = _showIncomeChart ? 'Доходы по категориям' : (_selectedCategory != null ? 'Расходы по подкатегориям ($_selectedCategory)' : 'Расходы по категориям');

    return Scaffold(
      appBar: AppBar(
        title: Text('Аналитика'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
                if (value == 'Месяц') {
                  _startDate = DateTime.now().subtract(Duration(days: 30));
                  _endDate = DateTime.now();
                } else if (value == '3 месяца') {
                  _startDate = DateTime.now().subtract(Duration(days: 90));
                  _endDate = DateTime.now();
                } else if (value == 'Год') {
                  _startDate = DateTime.now().subtract(Duration(days: 365));
                  _endDate = DateTime.now();
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Месяц', child: Text('Месяц')),
              PopupMenuItem(value: '3 месяца', child: Text('3 месяца')),
              PopupMenuItem(value: 'Год', child: Text('Год')),
              PopupMenuItem(value: 'Пользовательский', child: Text('Выбрать период')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Период: $_periodDisplay',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Выберите счёт:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedAccountNumber,
                hint: Text('Все счета'),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Все счета'),
                  ),
                  ...widget.accounts.map((account) => DropdownMenuItem<String>(
                    value: account.number,
                    child: Text(account.name, overflow: TextOverflow.ellipsis),
                  )),
                ],
                onChanged: (value) => setState(() => _selectedAccountNumber = value),
              ),
              SizedBox(height: 16),
              Text(
                'Доходы: ${_totalIncome.toStringAsFixed(2)} руб.',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              ..._incomeByCategory.entries.map((entry) => Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)} руб.',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              SizedBox(height: 16),
              Text(
                'Расходы: ${_totalExpenses.toStringAsFixed(2)} руб.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              ..._expensesByCategory.entries.map((entry) => Padding(
                padding: EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)} руб.',
                  overflow: TextOverflow.ellipsis,
                ),
              )),
              SizedBox(height: 16),
              if (!_showIncomeChart && _expensesByCategory.isNotEmpty) ...[
                Text(
                  'Выберите категорию:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Все категории'),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Все категории'),
                    ),
                    ..._expensesByCategory.keys.map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, overflow: TextOverflow.ellipsis),
                    )),
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                if (_selectedCategory != null) ...[
                  SizedBox(height: 16),
                  Text(
                    'Средние расходы за $_periodDisplay:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ..._averageExpenses.entries.map((entry) => Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'По "${entry.key}": ${entry.value.toStringAsFixed(2)} руб.',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                ],
              ],
              SizedBox(height: 16),
              Text(
                chartTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => setState(() => _showIncomeChart = !_showIncomeChart),
                child: Text(_showIncomeChart ? 'Показать расходы' : 'Показать доходы'),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: chartData.isEmpty
                    ? Center(child: Text('Нет данных для отображения'))
                    : PieChart(
                  PieChartData(
                    sections: chartData.entries.map((entry) {
                      final index = chartData.keys.toList().indexOf(entry.key);
                      final total = _showIncomeChart ? _totalIncome : (_selectedCategory != null ? _totalSelectedExpenses : _totalExpenses);
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
                        color: Colors.primaries[index % Colors.primaries.length],
                        radius: _touchedIndex == index ? 90 : 80,
                        titleStyle: TextStyle(fontSize: 12, color: Colors.white),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (event is FlTapDownEvent && pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                            _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          } else if (event is FlTapUpEvent || event is FlLongPressEnd) {
                            _touchedIndex = null;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (chartData.isNotEmpty) ...[
                Text(
                  'Категории:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...chartData.entries.map((entry) {
                  final index = chartData.keys.toList().indexOf(entry.key);
                  final color = Colors.primaries[index % Colors.primaries.length];
                  final icon = _categoryIcons[entry.key] ?? Icons.category;
                  final isHighlighted = _touchedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Container(
                      color: isHighlighted ? Colors.grey[200] : null,
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        children: [
                          Icon(icon, size: 20, color: color),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${entry.key}: ${entry.value.toStringAsFixed(2)} руб.',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              SizedBox(height: 16),
              Text(
                'Рекомендации:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _totalExpenses > _totalIncome
                    ? 'Ваши расходы превышают доходы. Попробуйте сократить траты в категориях с наибольшими суммами.'
                    : _totalExpenses < _totalIncome
                    ? 'Ваши доходы превышают расходы. Рассмотрите возможность инвестирования излишков.'
                    : 'Ваши доходы равны расходам. Старайтесь поддерживать баланс или планировать бюджет для будущих целей.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}