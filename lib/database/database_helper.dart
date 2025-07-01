import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/account.dart';
import '../models/financial_goal.dart';
import '../models/family.dart';
import '../models/account_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    // Проверяем наличие тестового пользователя
    final db = _database!;
    final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    if (userCount == 0) {
      await _createTestUser(db);
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'family_finance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        familyId TEXT,
        role TEXT,
        token TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts(
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT,
        balance REAL,
        number TEXT,
        type TEXT,
        currency TEXT,
        category TEXT,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE account_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId TEXT,
        historyDate TEXT,
        amount REAL,
        type TEXT,
        relatedAccount TEXT,
        category TEXT,
        subcategory TEXT,
        FOREIGN KEY(accountId) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE financial_goals(
        id TEXT PRIMARY KEY,
        userId TEXT,
        description TEXT,
        requiredAmount REAL,
        totalAmount REAL,
        deadlineDate TEXT,
        accountName TEXT,
        goalCategory TEXT,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE families(
        id TEXT PRIMARY KEY,
        name TEXT,
        inviteCode TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE family_members(
        familyId TEXT,
        userId TEXT,
        PRIMARY KEY(familyId, userId),
        FOREIGN KEY(familyId) REFERENCES families(id) ON DELETE CASCADE,
        FOREIGN KEY(userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Создаем тестового пользователя
    await _createTestUser(db);
  }

  Future<void> _createTestUser(Database db) async {
    final testUser = User(
      id: 'test_user_1',
      name: 'Тестовый Пользователь',
      email: 'test@example.com',
      password: 'test123',
      familyId: 'family_1',
      role: UserRole.adult,
      token: 'test_user_1',
      accounts: [
        Account(
          id: 'account_1',
          name: 'Основной счет',
          balance: 10000.0,
          number: '1234567890',
          type: 'cash',
          currency: 'RUB',
          category: 'main',
          history: [
            AccountHistory(
              id: null,
              historyDate: DateTime.now(),
              amount: 500.0,
              type: 'income',
              relatedAccount: '',
              category: 'Зарплата',
              subcategory: '',
            ),
          ],
        ),
      ],
      goals: [
        FinancialGoal(
          id: 'goal_1',
          userId: 'test_user_1',
          description: 'Отпуск',
          requiredAmount: 50000.0,
          totalAmount: 10000.0,
          deadlineDate: DateTime(2025, 12, 31),
          accountName: 'Основной счет',
          goalCategory: 'Путешествия',
        ),
      ],
    );

    await db.insert('users', testUser.toJson());
    await db.insert('families', {
      'id': 'family_1',
      'name': 'Тестовая Семья',
      'inviteCode': 'TEST123',
    });
    await db.insert('family_members', {
      'familyId': 'family_1',
      'userId': 'test_user_1',
    });
    for (var account in testUser.accounts) {
      final accountMap = account.toJson();
      accountMap['userId'] = 'test_user_1';
      await db.insert('accounts', accountMap);
      for (var history in account.history) {
        await db.insert('account_history', {
          'accountId': account.id,
          'historyDate': history.historyDate.toIso8601String(),
          'amount': history.amount,
          'type': history.type,
          'relatedAccount': history.relatedAccount,
          'category': history.category,
          'subcategory': history.subcategory,
        });
      }
    }
    for (var goal in testUser.goals) {
      final goalMap = goal.toJson();
      goalMap['id'] = goal.id; // Добавляем id
      goalMap['userId'] = goal.userId; // Добавляем userId
      await db.insert('financial_goals', goalMap);
    }
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toJson(),
      where: 'number = ?',
      whereArgs: [account.number],
    );
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    final userMap = user.toJson();
    final userId = await db.insert('users', userMap, conflictAlgorithm: ConflictAlgorithm.replace);
    for (final goal in user.goals) {
      await insertFinancialGoal(goal);
    }
    return userId;
  }

  Future<int> insertFinancialGoal(FinancialGoal goal) async {
    final db = await database;
    final goalMap = goal.toJson();
    goalMap['id'] = goal.id;
    goalMap['userId'] = goal.userId;
    return await db.insert('financial_goals', goalMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FinancialGoal>> getFinancialGoals(String userId) async {
    final db = await database;
    final maps = await db.query('financial_goals', where: 'userId = ?', whereArgs: [userId]);
    return maps.map((map) => FinancialGoal.fromJson(map)).toList();
  }

  Future<User?> getUser(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      final user = User.fromJson(maps.first);
      user.accounts = await getAccounts(user.id);
      for (final account in user.accounts) {
        account.history = await getAccountHistory(account.id);
      }
      user.goals = await getFinancialGoals(user.id);
      return user;
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'email = ?',
      whereArgs: [user.email],
    );
  }

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Account>> getAccounts(String userId) async {
    final db = await database;
    final maps = await db.query(
      'accounts',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Account.fromJson(map)).toList();
  }

  Future<int> insertAccountHistory(AccountHistory history, String accountId) async {
    final db = await database;
    final historyMap = history.toJson();
    historyMap['accountId'] = accountId;
    return await db.insert('account_history', historyMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AccountHistory>> getAccountHistory(String accountId) async {
    final db = await database;
    final historyMaps = await db.query(
      'account_history',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return historyMaps.map((map) => AccountHistory.fromJson(map)).toList();
  }

  Future<int> insertFamily(Family family) async {
    final db = await database;
    await db.insert('families', {
      'id': family.id,
      'name': family.name,
      'inviteCode': family.inviteCode,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    for (final user in family.users) {
      await db.insert('family_members', {
        'familyId': family.id,
        'userId': user.id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return 1;
  }

  Future<Family?> getFamily(String familyId) async {
    final db = await database;
    final familyMap = await db.query(
      'families',
      where: 'id = ?',
      whereArgs: [familyId],
      limit: 1,
    );

    if (familyMap.isEmpty) return null;

    final members = await db.query(
      'family_members',
      where: 'familyId = ?',
      whereArgs: [familyId],
    );

    final users = <User>[];
    for (var member in members) {
      final user = await getUser(member['userId'] as String);
      if (user != null) {
        users.add(user);
      }
    }

    return Family(
      id: familyMap.first['id'] as String,
      name: familyMap.first['name'] as String,
      users: users,
      inviteCode: familyMap.first['inviteCode'] as String,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<int> updateAccountWithHistory(Account account) async {
    final db = await database;
    await db.transaction((txn) async {
      final accountMap = Map<String, dynamic>.from(account.toJson());
      accountMap.remove('history');
      await txn.update(
        'accounts',
        accountMap,
        where: 'number = ?',
        whereArgs: [account.number],
      );
      for (final h in account.history.where((h) => h.id == null)) {
        await txn.insert('account_history', {
          'accountId': account.number,
          'historyDate': h.historyDate.toIso8601String(),
          'amount': h.amount,
          'type': h.type,
          'relatedAccount': h.relatedAccount,
          'category': h.category,
          'subcategory': h.subcategory,
        });
      }
    });
    return 1;
  }
}