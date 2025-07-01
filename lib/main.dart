import 'dart:convert'; // Добавить для jsonDecode
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/user.dart';
import 'models/family.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/main_screen.dart'; // Импортируем MainScreen
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();
  SharedPreferences.setPrefix('');
  final prefs = await SharedPreferences.getInstance();

  String initialRoute = '/login';
  Object? initialArguments;

  try {
    final token = await storage.read(key: 'auth_token');
    final familyId = prefs.getString('current_family_id');

    if (token != null && familyId != null) {
      final familyJson = prefs.getString('family_$familyId');

      if (familyJson != null) {
        final familyData = jsonDecode(familyJson);
        final family = Family.fromJson(familyData);

        initialRoute = '/main';
        initialArguments = {
          'user': family.users.firstWhere(
                (u) => u.token == token,
            orElse: () => family.users.first,
          ),
          'family': family,
        };
      } else {
        final user = await ApiService.getProfile(token);
        initialRoute = '/main';
        initialArguments = {
          'user': user,
          'family': Family(
            id: user.familyId,
            name: "Семья ${user.name}",
            users: [user],
            inviteCode: '',
          ),
        };
      }
    } else if (token != null) {
      final user = await ApiService.getProfile(token);
      initialRoute = '/main';
      initialArguments = {
        'user': user,
        'family': Family(
          id: user.familyId,
          name: "Семья ${user.name}",
          users: [user],
          inviteCode: '',
        ),
      };
    }
  } catch (e) {
    await storage.delete(key: 'auth_token');
    print('Ошибка проверки токена: $e');
  }

  runApp(FamilyFinanceApp(
    initialRoute: initialRoute,
    initialArguments: initialArguments,
  ));
}

class FamilyFinanceApp extends StatelessWidget {
  final String initialRoute;
  final Object? initialArguments;

  const FamilyFinanceApp({
    required this.initialRoute,
    this.initialArguments,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расходы семьи',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/main': (context) {
          final args = initialArguments as Map<String, dynamic>?;
          return MainScreen(
            accounts: args?['user']?.accounts ?? [],
            goals: args?['user']?.goals ?? [],
            onAddAccount: (newAccount) {
              // Здесь будет логика добавления счета через API
            },
            family: args?['family'] ?? Family(
              id: '',
              name: '',
              users: [],
              inviteCode: '', // Добавляем здесь
            ),
            currentUser: args?['user'] ?? User(
              name: '',
              email: '',
              password: '',
              familyId: '',
              role: UserRole.adult,
            ),
          );
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MainScreen(
              accounts: args?['user']?.accounts ?? [],
              goals: args?['user']?.goals ?? [],
              onAddAccount: (newAccount) {},
              family: args?['family'] ?? Family(
                id: '',
                name: '',
                users: [],
                inviteCode: '', // И здесь
              ),
              currentUser: args?['user'] ?? User(
                name: '',
                email: '',
                password: '',
                familyId: '',
                role: UserRole.adult,
              ),
            ),
          );
        }
        return null;
      },
    );
  }
}