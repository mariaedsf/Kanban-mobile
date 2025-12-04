import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'tasks_screen.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  String _userName = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userId = user.id;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban - $_userName'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/Logo.png',
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Bem-vindo, $_userName!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Seu Kanban pessoal esta pronto para uso',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_userId.isNotEmpty)
                KanbanPreview(userId: _userId)
              else
                const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      'Minhas Tarefas',
                      Icons.task_alt,
                      Colors.blue,
                      () => Navigator.pushNamed(
                        context,
                        '/tasks',
                        arguments: _userId,
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Nova Tarefa',
                      Icons.add_circle,
                      Colors.green,
                      () => Navigator.pushNamed(
                        context,
                        '/task-form',
                        arguments: _userId,
                      ),
                    ),
                    _buildFeatureCard(
                      context,
                      'Configuracoes',
                      Icons.settings,
                      Colors.grey,
                      () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KanbanPreview extends StatelessWidget {
  const KanbanPreview({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    final tasks = FirebaseFirestore.instance.collection('tasks');

    Widget column(String label, String status) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: tasks
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: status)
            .limit(2)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 64,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return Text('Sem cards em $label');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: docs.map((doc) {
              final data = doc.data();
              final title = data['title'] as String? ?? 'Sem titulo';
              final priority = _priorityLabel(data['priority'] as String?);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('$title - $priority'),
              );
            }).toList(),
          );
        },
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo rapido',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To-do',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      column('To-do', 'todo'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doing',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      column('Doing', 'inProgress'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _priorityLabel(String? priority) {
    switch (priority) {
      case 'high':
        return 'Alta';
      case 'low':
        return 'Baixa';
      case 'medium':
      default:
        return 'Media';
    }
  }
}




