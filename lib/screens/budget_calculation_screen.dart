import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/account_history.dart';

class BudgetCalculationScreen extends StatefulWidget {
  final List<Account> accounts;

  const BudgetCalculationScreen({required this.accounts});

  @override
  _BudgetCalculationScreenState createState() => _BudgetCalculationScreenState();
}

class _BudgetCalculationScreenState extends State<BudgetCalculationScreen> {
  double _reservePercentage = 10.0; // Процент резерва по умолчанию

  // Рассчитывает основные финансовые показатели по формулам
  Map<String, dynamic> calculateBudgetMetrics() {
    double totalIncome = 0;
    double mandatoryExpenses = 0;
    double plannedExpenses = 0;
    double unplannedExpenses = 0;
    double reserve = 0;
    double alpha = _reservePercentage / 100; // Используем выбранный процент

    Map<String, double> incomeByCategory = {
      'Зарплаты': 0,
      'Инвестиции': 0,
      'Пособия': 0,
      'Другие': 0
    };

    // Группируем расходы по типам
    Map<String, double> mandatoryExpensesByCategory = {
      'ЖКХ': 0,
      'Питание': 0,
      'Транспорт': 0,
      'Кредиты': 0,
      'Медицина': 0,
    };

    Map<String, double> plannedExpensesByCategory = {
      'Образование': 0,
      'Хобби': 0,
      'Красота': 0,
      'Супермаркеты': 0,
      'Подарки': 0,
    };

    Map<String, double> unplannedExpensesByCategory = {
      'Развлечения': 0,
      'Спорт': 0,
      'Одежда': 0,
      'Маркетплейсы': 0,
      'Прочее': 0
    };

    for (final account in widget.accounts) {
      for (final history in account.history) {
        final amount = history.amount;
        final category = history.category ?? '';
        final subcategory = history.subcategory ?? '';

        if (amount > 0) {
          totalIncome += amount;

          if (category == 'Зарплата') {
            incomeByCategory['Зарплаты'] = incomeByCategory['Зарплаты']! + amount;
          } else if (category == 'Инвестиции') {
            incomeByCategory['Инвестиции'] = incomeByCategory['Инвестиции']! + amount;
          } else if (category == 'Пособия') {
            incomeByCategory['Пособия'] = incomeByCategory['Пособия']! + amount;
          } else {
            incomeByCategory['Другие'] = incomeByCategory['Другие']! + amount;
          }
        }
        else if (amount < 0) {
          final absAmount = amount.abs();

          if (category == 'Жилье') {
            mandatoryExpenses += absAmount;
            mandatoryExpensesByCategory['ЖКХ'] = mandatoryExpensesByCategory['ЖКХ']! + absAmount;
          }
          else if (category == 'Продукты') {
            mandatoryExpenses += absAmount;
            mandatoryExpensesByCategory['Питание'] = mandatoryExpensesByCategory['Питание']! + absAmount;
          }
          else if (category == 'Транспорт') {
            mandatoryExpenses += absAmount;
            mandatoryExpensesByCategory['Транспорт'] = mandatoryExpensesByCategory['Транспорт']! + absAmount;
          }
          else if (category == 'Кредиты') {
            mandatoryExpenses += absAmount;
            mandatoryExpensesByCategory['Кредиты'] = mandatoryExpensesByCategory['Кредиты']! + absAmount;
          }
          else if (category == 'Здоровье') {
            mandatoryExpenses += absAmount;
            mandatoryExpensesByCategory['Медицина'] = mandatoryExpensesByCategory['Медицина']! + absAmount;
          }
          else if (category == 'Образование') {
            plannedExpenses += absAmount;
            plannedExpensesByCategory['Образование'] = plannedExpensesByCategory['Образование']! + absAmount;
          }
          else if (category == 'Хобби' || subcategory == 'Хобби') {
            plannedExpenses += absAmount;
            plannedExpensesByCategory['Хобби'] = plannedExpensesByCategory['Хобби']! + absAmount;
          }
          else if (category == 'Красота') {
            plannedExpenses += absAmount;
            plannedExpensesByCategory['Красота'] = plannedExpensesByCategory['Красота']! + absAmount;
          }
          else if (category == 'Супермаркеты/магазины') {
            plannedExpenses += absAmount;
            plannedExpensesByCategory['Супермаркеты'] = plannedExpensesByCategory['Супермаркеты']! + absAmount;
          }
          else if (category == 'Подарки') {
            plannedExpenses += absAmount;
            plannedExpensesByCategory['Подарки'] = plannedExpensesByCategory['Подарки']! + absAmount;
          }
          else if (category == 'Развлечения') {
            unplannedExpenses += absAmount;
            unplannedExpensesByCategory['Развлечения'] = unplannedExpensesByCategory['Развлечения']! + absAmount;
          }
          else if (category == 'Спорт') {
            unplannedExpenses += absAmount;
            unplannedExpensesByCategory['Спорт'] = unplannedExpensesByCategory['Спорт']! + absAmount;
          }
          else if (category == 'Одежда и обувь') {
            unplannedExpenses += absAmount;
            unplannedExpensesByCategory['Одежда'] = unplannedExpensesByCategory['Одежда']! + absAmount;
          }
          else if (category == 'Маркетплейсы') {
            unplannedExpenses += absAmount;
            unplannedExpensesByCategory['Маркетплейсы'] = unplannedExpensesByCategory['Маркетплейсы']! + absAmount;
          }
          else if (category == 'Прочее') {
            unplannedExpenses += absAmount;
            unplannedExpensesByCategory['Прочее'] = unplannedExpensesByCategory['Прочее']! + absAmount;
          }
        }
      }
    }

    reserve = totalIncome - (mandatoryExpenses + plannedExpenses + unplannedExpenses);
    double minReserve = totalIncome * alpha;

    return {
      'totalIncome': totalIncome,
      'mandatoryExpenses': mandatoryExpenses,
      'plannedExpenses': plannedExpenses,
      'unplannedExpenses': unplannedExpenses,
      'reserve': reserve,
      'minReserve': minReserve,
      'alpha': alpha,
      'incomeByCategory': incomeByCategory,
      'mandatoryExpensesByCategory': mandatoryExpensesByCategory,
      'plannedExpensesByCategory': plannedExpensesByCategory,
      'unplannedExpensesByCategory': unplannedExpensesByCategory,
    };
  }

  @override
  Widget build(BuildContext context) {
    final metrics = calculateBudgetMetrics();
    final incomeByCategory = metrics['incomeByCategory'] as Map<String, double>;
    final mandatoryExpensesByCategory = metrics['mandatoryExpensesByCategory'] as Map<String, double>;
    final plannedExpensesByCategory = metrics['plannedExpensesByCategory'] as Map<String, double>;
    final unplannedExpensesByCategory = metrics['unplannedExpensesByCategory'] as Map<String, double>;

    return Scaffold(
      appBar: AppBar(title: const Text('Расчет бюджета')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Доходы по категориям
              const Text(
                'Доходы по категориям:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...incomeByCategory.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value.toStringAsFixed(2)} руб.'),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),

              // Основные метрики
              _buildMetricCard(
                'Общий доход семьи',
                metrics['totalIncome'] as double,
                Colors.green,
                Icons.arrow_upward,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'Обязательные расходы',
                metrics['mandatoryExpenses'] as double,
                Colors.blue,
                Icons.home,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'Запланированные расходы',
                metrics['plannedExpenses'] as double,
                Colors.orange,
                Icons.calendar_today,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'Незапланированные расходы',
                metrics['unplannedExpenses'] as double,
                Colors.red,
                Icons.warning,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'Финансовый резерв',
                metrics['reserve'] as double,
                (metrics['reserve'] as double) >= 0 ? Colors.green : Colors.red,
                (metrics['reserve'] as double) >= 0 ? Icons.savings : Icons.error,
              ),
              const SizedBox(height: 16),

              // Настройка резерва (перемещена сюда)
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Настройка резерва:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Размер резерва: ${_reservePercentage.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Icon(Icons.settings, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: _reservePercentage,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label: _reservePercentage.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _reservePercentage = value;
                          });
                        },
                      ),
                      Text(
                        'Рекомендуемый резерв: ${(metrics['minReserve'] as double).toStringAsFixed(2)} руб.',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Текущий резерв: ${(metrics['reserve'] as double).toStringAsFixed(2)} руб.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: (metrics['reserve'] as double) >= (metrics['minReserve'] as double)
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Анализ
              _buildAnalysisSection(metrics),

              // Детализация расходов по группам
              const SizedBox(height: 24),
              _buildExpenseGroup(
                'Обязательные расходы',
                mandatoryExpensesByCategory,
                Icons.lock_clock,
                Colors.blue,
              ),
              const SizedBox(height: 24),
              _buildExpenseGroup(
                'Запланированные расходы',
                plannedExpensesByCategory,
                Icons.calendar_month,
                Colors.orange,
              ),
              const SizedBox(height: 24),
              _buildExpenseGroup(
                'Незапланированные расходы',
                unplannedExpensesByCategory,
                Icons.warning,
                Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseGroup(String title, Map<String, double> expenses, IconData icon, Color color) {
    double total = expenses.values.fold(0, (sum, value) => sum + value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Итого: ${total.toStringAsFixed(2)} руб.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...expenses.entries.map((entry) {
          if (entry.value > 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text('${entry.value.toStringAsFixed(2)} руб.'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ],
    );
  }

  Widget _buildMetricCard(String title, double value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16)),
                  Text(
                    '${value.toStringAsFixed(2)} руб.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(Map<String, dynamic> metrics) {
    final reserve = metrics['reserve'] as double;
    final minReserve = metrics['minReserve'] as double;
    final alpha = metrics['alpha'] as double;
    String analysis = '';
    Color color = Colors.green;

    if (reserve < 0) {
      analysis = 'Внимание! Дефицит бюджета. Рекомендуем сократить расходы.';
      color = Colors.red;
    } else if (reserve < minReserve) {
      analysis = 'Минимальный резерв (рекомендуемый: ${(alpha*100).toInt()}% от дохода). '
          'Рекомендуем увеличить накопления.';
      color = Colors.orange;
    } else {
      analysis = 'Финансовое положение стабильное. Хороший уровень резерва.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Анализ бюджета:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          analysis,
          style: TextStyle(fontSize: 16, color: color),
        ),
        const SizedBox(height: 16),
        const Text(
          'Структура расходов:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildExpenseStructure(metrics),
      ],
    );
  }

  Widget _buildExpenseStructure(Map<String, dynamic> metrics) {
    final totalExpenses = (metrics['mandatoryExpenses'] as double) +
        (metrics['plannedExpenses'] as double) +
        (metrics['unplannedExpenses'] as double);

    return Column(
      children: [
        _buildProgressRow('Обязательные', metrics['mandatoryExpenses'] as double, totalExpenses, Colors.blue),
        _buildProgressRow('Запланированные', metrics['plannedExpenses'] as double, totalExpenses, Colors.orange),
        _buildProgressRow('Незапланированные', metrics['unplannedExpenses'] as double, totalExpenses, Colors.red),
      ],
    );
  }

  Widget _buildProgressRow(String label, double value, double total, Color color) {
    final percentage = total > 0 ? (value / total * 100) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$label:'),
              Text('${value.toStringAsFixed(2)} руб. (${percentage.toStringAsFixed(1)}%)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            color: color,
          ),
        ],
      ),
    );
  }
}