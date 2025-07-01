import '../models/user.dart';

class MockApiService {
  // Имитация задержки сети
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Тестовый пользователь
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


  static Future<User> login(String email, String password) async {
    await _simulateNetworkDelay();

    if (email == "test@test.com" && password == "pavel123") {
      return _mockUser;
    } else {
      throw Exception("Неверный email или пароль");
    }
  }

  // Регистрация (заглушка)
  static Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateNetworkDelay();
    return _mockUser.copyWith(name: name, email: email);
  }

  // Получение профиля (заглушка)
  static Future<User> getProfile(String token) async {
    await _simulateNetworkDelay();
    return _mockUser;
  }
}