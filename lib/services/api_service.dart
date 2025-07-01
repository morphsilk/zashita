import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const bool useMock = true;
  static const String _baseUrl = 'http://172.20.10.2';

  static final User _mockUser = User(
    name: "Павел",
    email: "test@test.com",
    password: "pavel123",
    familyId: "",
    role: UserRole.admin,
    token: "mock-token-123",
    accounts: [],
    goals: [],
  );

  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  static Future<void> testConnection() async {
    if (useMock) {
      await _simulateNetworkDelay();
      print('[MOCK] Connection test successful');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Connection test error: $e');
      throw Exception('Connection failed');
    }
  }

  static Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (useMock) {
      await _simulateNetworkDelay();
      return _mockUser.copyWith(
        name: name,
        email: email,
        password: password,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['error'] ?? 'Ошибка регистрации');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Не удалось зарегистрироваться. Проверьте подключение');
    }
  }

  static Future<User> login(String email, String password) async {
    if (useMock) {
      await _simulateNetworkDelay();
      if (email == "test@test.com" && password == "pavel123") {
        return _mockUser;
      } else {
        throw Exception("Неверный email или пароль");
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } catch (e) {
      rethrow;
    }
  }


  static Future<User> getProfile(String token) async {
    if (useMock) {
      await _simulateNetworkDelay();
      return _mockUser;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromJson(data);
      } else {
        throw Exception(data['error'] ?? 'Ошибка получения профиля');
      }
    } on SocketException {
      throw Exception('Нет подключения к серверу');
    } catch (e) {
      if (e is TimeoutException) {
        throw Exception('Превышено время ожидания');
      }
      throw Exception('Ошибка: ${e.toString()}');
    }
  }

  static Future<User> joinFamily({
    required String inviteCode,
    required String name,
    required String email,
    required String password,
  }) async {
    if (useMock) {
      await _simulateNetworkDelay();
      return _mockUser.copyWith(
        name: name,
        email: email,
        password: password,
        familyId: "FAM${inviteCode.substring(0, 4)}",
        role: UserRole.adult,
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/join-family'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'inviteCode': inviteCode,
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['error'] ?? 'Ошибка присоединения к семье');
      }
    } catch (e) {
      print('Join family error: $e');
      throw Exception('Не удалось присоединиться к семье. Проверьте код приглашения');
    }
  }
}