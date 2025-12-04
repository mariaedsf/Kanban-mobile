import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'kanban_users';
  static const String _currentUserKey = 'kanban_current_user';

  Future<bool> register(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      List<User> users = [];
      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        users = usersList.map((json) => User.fromJson(json)).toList();
      }

      // Verificar se o email já existe
      if (users.any((user) => user.email == email)) {
        return false;
      }

      // Criar novo usuário
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        password: password, // Em um app real, isso seria hash
      );

      users.add(newUser);

      // Salvar usuários
      final updatedUsersJson = json.encode(users.map((user) => user.toJson()).toList());
      await prefs.setString(_usersKey, updatedUsersJson);

      // Salvar usuário atual
      await prefs.setString(_currentUserKey, json.encode(newUser.toJson()));

      return true;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) {
        return false;
      }

      final List<dynamic> usersList = json.decode(usersJson);
      final users = usersList.map((json) => User.fromJson(json)).toList();

      // Procurar usuário com email e senha
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => User(id: '', email: '', name: '', password: ''),
      );

      if (user.id.isNotEmpty) {
        // Salvar usuário atual
        await prefs.setString(_currentUserKey, json.encode(user.toJson()));
        return true;
      }

      return false;
    } catch (e) {
      print('Erro ao fazer login: $e');
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);
      
      if (currentUserJson == null) {
        return null;
      }

      final userMap = json.decode(currentUserJson);
      return User.fromJson(userMap);
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}