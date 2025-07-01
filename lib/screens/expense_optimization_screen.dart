import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ExpenseOptimizationScreen extends StatefulWidget {
  final double totalUnplannedExpenses;
  final Map<String, double> unplannedExpensesByCategory;

  const ExpenseOptimizationScreen({
    required this.totalUnplannedExpenses,
    required this.unplannedExpensesByCategory,
    Key? key,
  }) : super(key: key);

  @override
  _ExpenseOptimizationScreenState createState() => _ExpenseOptimizationScreenState();
}

class _ExpenseOptimizationScreenState extends State<ExpenseOptimizationScreen> {
  final Map<String, int> _priorities = {
    'Развлечения': 5,
    'Спорт': 5,
    'Одежда': 5,
    'Маркетплейсы': 5,
    'Прочее': 5,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оптимизация расходов')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий бюджет на оптимизацию: ${widget.totalUnplannedExpenses.toStringAsFixed(2)} руб.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Текущие расходы по категориям:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...widget.unplannedExpensesByCategory.entries.map((entry) {
              if (entry.value > 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
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
            }),
            const SizedBox(height: 20),
            const Text(
              'Установите приоритеты для оптимизации (1-10):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ..._priorities.entries.map((entry) => _buildPrioritySlider(entry.key, entry.value)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Здесь будет логика оптимизации
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Оптимизация выполнена')),
                );
                Navigator.pop(context);
              },
              child: const Text('Применить оптимизацию'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySlider(String category, int priority) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category),
        Slider(
          value: priority.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: priority.toString(),
          onChanged: (value) {
            setState(() {
              _priorities[category] = value.toInt();
            });
          },
        ),
      ],
    );
  }
}