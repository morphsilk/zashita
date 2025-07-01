// lib/screens/add_account_screen.dart
import 'package:flutter/material.dart';
import '../models/account.dart';

class AddAccountScreen extends StatefulWidget {
  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _balance = 0.0;
  String _type = 'Наличные';
  String _currency = 'RUB';
  String? _category; // Null, если вручную
  bool _useCategory = false; // Переключатель: категория или ручной ввод

  final List<String> _categories = [
    'Ежедневные расходы',
    'Сбережения',
    'Инвестиции',
    'Другое',
  ];

  final List<String> _types = [
    'Наличные',
    'Карта',
    'Банковский счёт',
    'Кредит',
    'Депозит',
  ];

  final List<String> _currencies = [
    'RUB',
    'USD',
    'EUR',
  ];

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newAccount = Account(
        name: _useCategory ? _category! : _name, // Используем категорию или имя
        balance: _balance,
        type: _type,
        currency: _currency,
        category: _useCategory ? _category : null,
      );
      Navigator.pop(context, newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить счёт')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  title: Text('Выбрать из категорий'),
                  value: _useCategory,
                  onChanged: (value) {
                    setState(() {
                      _useCategory = value;
                      if (value && _category == null) {
                        _category = _categories[0]; // Устанавливаем первую категорию
                      }
                    });
                  },
                ),
                if (_useCategory)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Категория'),
                    value: _category,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _category = value!;
                      });
                    },
                    validator: (value) =>
                    value == null ? 'Выберите категорию' : null,
                  )
                else
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Название счёта'),
                    validator: (value) =>
                    value!.isEmpty ? 'Введите название' : null,
                    onSaved: (value) => _name = value!,
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Текущий баланс'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Введите баланс';
                    if (double.tryParse(value) == null) return 'Введите число';
                    return null;
                  },
                  onSaved: (value) => _balance = double.parse(value!),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Тип счёта'),
                  value: _type,
                  items: _types.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Выберите тип' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Валюта'),
                  value: _currency,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _currency = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Выберите валюту' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveAccount,
                  child: Text('Сохранить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}