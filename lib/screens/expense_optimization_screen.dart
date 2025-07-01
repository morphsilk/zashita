import 'package:flutter/material.dart';

class ExpenseOptimizationScreen extends StatefulWidget {
  final double totalUnplannedExpenses;
  final Map<String, double> unplannedExpenses;

  const ExpenseOptimizationScreen({
    required this.totalUnplannedExpenses,
    required this.unplannedExpenses,
    Key? key,
  }) : super(key: key);

  @override
  _ExpenseOptimizationScreenState createState() => _ExpenseOptimizationScreenState();
}

class _ExpenseOptimizationScreenState extends State<ExpenseOptimizationScreen> {
  // Приоритеты для каждой категории
  final Map<String, int> _priorities = {
    'Развлечения': 5,
    'Спорт': 5,
    'Одежда': 1,
    'Маркетплейсы': 10,
    'Прочее': 3,
  };

  // Лимиты для каждой группы уравнений
  final Map<String, double> _limits = {
    'group1': 4000,
    'group2': 5000,
    'group3': 8000,
    'group4': 3000,
  };

  // Инициализируем значения по умолчанию
  Map<String, double> _optimalValues = {
    'x1': 0,
    'x2': 0,
    'x3': 0,
    'x4': 0,
    'x5': 0,
  };

  @override
  void initState() {
    super.initState();
    _calculateOptimalValues();
  }

  void _calculateOptimalValues() {
    // Временные переменные для расчетов
    double x3 = _limits['group2']! / (_priorities['Спорт']! + 1);
    double x1 = _limits['group1']! / _priorities['Развлечения']!;
    double x4 = _limits['group3']! / _priorities['Маркетплейсы']!;
    double x5 = (_limits['group4']! - _priorities['Развлечения']! * x1) / _priorities['Прочее']!;
    double x2 = (_limits['group2']! - x3) / _priorities['Спорт']!;

    setState(() {
      _optimalValues = {
        'x1': x1,
        'x2': x2,
        'x3': x3,
        'x4': x4,
        'x5': x5,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _optimalValues.values.fold(0.0, (sum, value) => sum + value);

    return Scaffold(
      appBar: AppBar(title: const Text('Оптимизация расходов')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Общий бюджет на оптимизацию',
              '${widget.totalUnplannedExpenses.toStringAsFixed(2)} руб.',
            ),

            const SizedBox(height: 20),
            const Text(
              'Рекомендуемые лимиты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildOptimizationCard(
              'Развлечения (x₁)',
              _optimalValues['x1'] ?? 0,
              _priorities['Развлечения'] ?? 0,
            ),
            _buildOptimizationCard(
              'Спорт (x₂)',
              _optimalValues['x2'] ?? 0,
              _priorities['Спорт'] ?? 0,
            ),
            _buildOptimizationCard(
              'Одежда (x₃)',
              _optimalValues['x3'] ?? 0,
              _priorities['Одежда'] ?? 0,
            ),
            _buildOptimizationCard(
              'Маркетплейсы (x₄)',
              _optimalValues['x4'] ?? 0,
              _priorities['Маркетплейсы'] ?? 0,
            ),
            _buildOptimizationCard(
              'Прочее (x₅)',
              _optimalValues['x5'] ?? 0,
              _priorities['Прочее'] ?? 0,
            ),

            const SizedBox(height: 20),
            _buildInfoCard(
              'Итого оптимальных расходов',
              '${total.toStringAsFixed(2)} руб. / ${widget.totalUnplannedExpenses.toStringAsFixed(2)} руб.',
              color: total <= widget.totalUnplannedExpenses ? Colors.green : Colors.orange,
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Рекомендации по оптимизации сохранены')),
                  );
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('Применить рекомендации', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationCard(String title, double value, int priority) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${value.toStringAsFixed(2)} руб.'),
              ],
            ),
            const SizedBox(height: 6),
            Text('Приоритет: $priority', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {Color color = Colors.blue}) {
    return Card(
      color: color.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}