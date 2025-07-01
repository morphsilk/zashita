// lib/models/income_category.dart
import 'package:flutter/material.dart';
import 'category.dart';

class IncomeCategory implements Category {
  @override
  final String name;
  @override
  final List<String> subcategories;

  IncomeCategory({
    required this.name,
    required this.subcategories,
  });
}

final List<IncomeCategory> incomeCategories = [
  IncomeCategory(name: 'Зарплата', subcategories: [
    'Основная работа',
    'Подработка',
    'Премия',
  ]),
  IncomeCategory(name: 'Инвестиции', subcategories: [
    'Дивиденды',
    'Проценты по вкладам',
    'Продажа акций',
  ]),
  IncomeCategory(name: 'Подарки', subcategories: [
    'День рождения',
    'Новый год',
    'Свадьба',
  ]),
  IncomeCategory(name: 'Прочее', subcategories: [
    'Возврат долга',
    'Кэшбэк',
    'Лотерея',
  ]),
];