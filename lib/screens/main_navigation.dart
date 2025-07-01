import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Добавить
import 'dart:convert'; // Добавить для jsonEncode/jsonDecode
import 'main_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'goals_budget_screen.dart';
import 'family_management_screen.dart';
import '../models/account.dart';
import '../models/financial_goal.dart';
import '../models/user.dart';
import '../models/family.dart';

class MainNavigation extends StatefulWidget {
  final Family family;

  const MainNavigation({required this.family, Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentTabIndex = 0;
  late User _currentUser;
  late Family _currentFamily;

  @override
  void initState() {
    super.initState();
    _currentFamily = widget.family;
    _currentUser = _findCurrentUser(_currentFamily.users);
    _loadFamilyState();
  }

  Future<void> _loadFamilyState() async {
    final prefs = await SharedPreferences.getInstance();
    final familyJson = prefs.getString('family_state_${_currentFamily.id}');

    if (familyJson != null) {
      try {
        final decoded = jsonDecode(familyJson);
        final updatedFamily = Family.fromJson(decoded);
        setState(() {
          _currentFamily = updatedFamily;
          _currentUser = _findCurrentUser(_currentFamily.users);
        });
      } catch (e) {
        print('Ошибка загрузки состояния семьи: $e');
      }
    }
  }

  Future<void> _saveFamilyState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'family_state_${_currentFamily.id}',
      jsonEncode(_currentFamily.toJson()),
    );
  }

  User _findCurrentUser(List<User> familyUsers) {
    try {
      return familyUsers.firstWhere(
            (user) => user.email == familyUsers.first.email,
        orElse: () => familyUsers.first,
      );
    } catch (e) {
      return User(
        name: 'Гость',
        email: '',
        password: '',
        familyId: '',
        role: UserRole.adult,
      );
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _handleAddAccount(Account newAccount) {
    setState(() {
      _currentUser.accounts.add(newAccount);
      _saveFamilyState();
    });
  }

  void _handleRemoveFamilyMember(User user) {
    setState(() {
      _currentFamily.users.removeWhere((u) => u.email == user.email);
      _saveFamilyState();
    });
  }

  void _handleUpdateRole(User user, UserRole newRole) {
    setState(() {
      final index = _currentFamily.users.indexWhere((u) => u.email == user.email);
      if (index != -1) {
        _currentFamily.users[index] = user.copyWith(role: newRole);
        _saveFamilyState();
      }
    });
  }

  void _handleAddFamilyMember(User newUser) {
    setState(() {
      _currentFamily.users.add(newUser);
      _saveFamilyState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newUser.name} добавлен в семью')),
      );
    });
  }

  void _navigateToFamilyManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FamilyManagementScreen(
          familyUsers: _currentFamily.users,
          onAddFamilyMember: _handleAddFamilyMember,
          onRemoveFamilyMember: _handleRemoveFamilyMember,
          onUpdateRole: _handleUpdateRole,
        ),
      ),
    ).then((_) => _saveFamilyState());
  }

  List<Widget> _buildScreens() {
    final familyAccounts = _currentUser.role == UserRole.child
        ? _currentUser.accounts
        : _currentFamily.users.expand((user) => user.accounts).toList();

    final familyGoals = _currentUser.role == UserRole.child
        ? _currentUser.goals
        : _currentFamily.users.expand((user) => user.goals).toList();

    return [
      MainScreen(
        accounts: familyAccounts,
        goals: familyGoals,
        onAddAccount: _currentUser.role != UserRole.child ? _handleAddAccount : null,
        family: _currentFamily,
        currentUser: _currentUser,
        onManageFamily: _currentUser.role == UserRole.admin ? _navigateToFamilyManagement : null,
      ),
      HistoryScreen(accounts: familyAccounts),
      AnalyticsScreen(accounts: familyAccounts),
      GoalsBudgetScreen(accounts: familyAccounts, goals: familyGoals),
    ];
  }
  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();
    final familyAccounts = _currentUser.role == UserRole.child
        ? _currentUser.accounts
        : _currentFamily.users.expand((user) => user.accounts).toList();

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Аналитика'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Цели'),
        ],
        currentIndex: _currentTabIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  void dispose() {
    _saveFamilyState();
    super.dispose();
  }
}