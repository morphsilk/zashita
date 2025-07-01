import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';

class FamilyManagementScreen extends StatefulWidget {
  final List<User> familyUsers;
  final Function(User) onAddFamilyMember;
  final Function(User) onRemoveFamilyMember;
  final Function(User, UserRole) onUpdateRole;

  const FamilyManagementScreen({
    required this.familyUsers,
    required this.onAddFamilyMember,
    required this.onRemoveFamilyMember,
    required this.onUpdateRole,
    Key? key,
  }) : super(key: key);

  @override
  _FamilyManagementScreenState createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.adult;
  String _generatedInviteCode = '';
  bool _showInviteSection = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generateInviteCode() {
    setState(() {
      final familyId = widget.familyUsers.first.familyId;
      final randomDigits = DateTime.now().millisecondsSinceEpoch.toString().substring(7, 11);
      _generatedInviteCode = '${familyId.substring(0, 4)}$randomDigits';
      _showInviteSection = true;
    });
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _generatedInviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Код скопирован в буфер обмена')),
    );
  }

  void _addFamilyMember() {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        familyId: widget.familyUsers.first.familyId,
        role: _role,
      );
      widget.onAddFamilyMember(newUser);

      // Очищаем поля после добавления
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() => _role = UserRole.adult);
    }
  }

  void _removeUser(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text('Вы уверены, что хотите удалить ${user.name} из семьи?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              widget.onRemoveFamilyMember(user);
              Navigator.pop(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateUserRole(User user, UserRole newRole) {
    if (user.role != newRole) {
      widget.onUpdateRole(user, newRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminUsers = widget.familyUsers.where((u) => u.role == UserRole.admin).toList();
    final canChangeRoles = adminUsers.length > 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Управление семьёй')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Члены семьи:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.familyUsers.length,
                itemBuilder: (context, index) {
                  final user = widget.familyUsers[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('${user.email} • ${user.role.toString().split('.').last}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.role != UserRole.admin || canChangeRoles)
                          DropdownButton<UserRole>(
                            value: user.role,
                            items: UserRole.values.map((role) {
                              return DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(role.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (newRole) {
                              if (newRole != null) {
                                _updateUserRole(user, newRole);
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeUser(user),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateInviteCode,
              child: const Text('Сгенерировать код приглашения'),
            ),
            if (_showInviteSection) ...[
              const SizedBox(height: 16),
              const Text('Код приглашения:', style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: _copyToClipboard,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _generatedInviteCode,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.content_copy, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Нажмите на код, чтобы скопировать. Отправьте его тому, кого хотите пригласить.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Добавить нового члена:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Имя'),
                    validator: (value) => value!.isEmpty ? 'Введите имя' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)
                        ? 'Введите корректный email'
                        : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Пароль'),
                    obscureText: true,
                    validator: (value) => value!.length < 8 ? 'Минимум 8 символов' : null,
                  ),
                  DropdownButtonFormField<UserRole>(
                    decoration: const InputDecoration(labelText: 'Роль'),
                    value: _role,
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(role.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _role = value!),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addFamilyMember,
                    child: const Text('Добавить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}