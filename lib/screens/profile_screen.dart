import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/family.dart';
import '../models/account.dart'; // Добавлен импорт Account
import 'budget_calculation_screen.dart';
import 'family_management_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Family family;
  final User currentUser;
  final List<Account> accounts;
  final Function(User)? onRemoveFamilyMember;
  final Function(User, UserRole)? onUpdateRole;

  const ProfileScreen({
    required this.family,
    required this.currentUser,
    required this.accounts,
    this.onRemoveFamilyMember,
    this.onUpdateRole,
    Key? key,
  }) : super(key: key);

  void _showFeatureInDevelopment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Функция в разработке'),
        content: const Text('Данная функция будет доступна в следующем обновлении.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выбор темы'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Светлая тема'),
              onTap: () {
                // Реализация смены темы
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Темная тема'),
              onTap: () {
                // Реализация смены темы
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_suggest),
              title: const Text('Системная тема'),
              onTap: () {
                // Реализация смены темы
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки уведомлений'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Операции по счетам'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Напоминания об оплате'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Финансовые отчеты'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Новости и советы'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showCurrencySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройки валюты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Рубли (RUB)'),
              value: 'RUB',
              groupValue: 'RUB',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Доллары (USD)'),
              value: 'USD',
              groupValue: 'RUB',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Евро (EUR)'),
              value: 'EUR',
              groupValue: 'RUB',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Применить'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из аккаунта'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Реализация выхода
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Информация о пользователе
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentUser.email,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Роль: ${currentUser.role.toString().split('.').last}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Основные функции
          _buildSectionTitle('Финансы'),
          _MenuItem(
            icon: Icons.calculate,
            title: 'Рассчитать бюджет',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetCalculationScreen(
                    accounts: accounts,
                  ),
                ),
              );
            },
          ),
          _MenuItem(
            icon: Icons.calendar_today,
            title: 'Платежный календарь',
            onTap: () => _showFeatureInDevelopment(context),
          ),
          _MenuItem(
            icon: Icons.notifications_active,
            title: 'Напоминания об оплате',
            onTap: () => _showFeatureInDevelopment(context),
          ),

          // Настройки
          _buildSectionTitle('Настройки'),
          _MenuItem(
            icon: Icons.color_lens,
            title: 'Тема оформления',
            onTap: () => _showThemeSelection(context),
          ),
          _MenuItem(
            icon: Icons.notifications,
            title: 'Уведомления',
            onTap: () => _showNotificationSettings(context),
          ),
          _MenuItem(
            icon: Icons.currency_exchange,
            title: 'Настройки валюты',
            onTap: () => _showCurrencySettings(context),
          ),

          // Обучение
          _buildSectionTitle('Обучение'),
          _MenuItem(
            icon: Icons.article,
            title: 'Статьи и советы',
            onTap: () => _showFeatureInDevelopment(context),
          ),

          // Управление семьей (только для админа)
          if (currentUser.role == UserRole.admin) ...[
            _buildSectionTitle('Управление семьей'),
            _MenuItem(
              icon: Icons.group,
              title: 'Управление семьёй',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FamilyManagementScreen(
                      familyUsers: family.users,
                      onAddFamilyMember: (newUser) {
                        Navigator.pop(context);
                        family.users.add(newUser);
                      },
                      onRemoveFamilyMember: onRemoveFamilyMember ?? (user) {
                        family.users.removeWhere((u) => u.email == user.email);
                      },
                      onUpdateRole: onUpdateRole ?? (user, newRole) {
                        final index = family.users.indexWhere((u) => u.email == user.email);
                        if (index != -1) {
                          family.users[index] = user.copyWith(role: newRole);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],

          // Выход
          _buildSectionTitle('Аккаунт'),
          _MenuItem(
            icon: Icons.exit_to_app,
            title: 'Выход',
            color: Colors.red,
            onTap: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

// Виджет для пункта меню вместо функции
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}