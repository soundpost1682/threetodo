import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../../../data/models/todo.dart';
import '../widgets/add_todo_dialog.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TodoProvider>().loadTodos(DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 3가지 할 일'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: 캘린더 화면으로 이동
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          final todos = todoProvider.todos;

          if (todos.isEmpty) {
            return const Center(child: Text('오늘의 할 일을 추가해보세요!'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: todos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoItemCard(todo: todo);
            },
          );
        },
      ),
      floatingActionButton: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return FutureBuilder<bool>(
            future: todoProvider.canAddTodoForToday(),
            builder: (context, snapshot) {
              final canAdd = snapshot.data ?? false;

              return FloatingActionButton(
                onPressed: canAdd ? () => _showAddTodoDialog(context) : null,
                child: const Icon(Icons.add),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddTodoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );
  }
}

class TodoItemCard extends StatelessWidget {
  final Todo todo;

  const TodoItemCard({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(todo.icon ?? '📝', style: const TextStyle(fontSize: 24)),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(todo.category),
        trailing: Checkbox(
          value: todo.isCompleted,
          onChanged: (bool? value) {
            context.read<TodoProvider>().toggleTodoStatus(todo);
          },
        ),
      ),
    );
  }
}
