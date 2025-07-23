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
        () => context.read<TodoProvider>().loadTodos(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 3가지 할 일'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          if (todoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final todos = todoProvider.todos;

          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '오늘의 3가지를 정해보세요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '작은 목표부터 시작해볼까요?',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTodoDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('할 일 추가하기'),
                  ),
                ],
              ),
            );
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
                backgroundColor:
                    canAdd ? Theme.of(context).primaryColor : Colors.grey,
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

  const TodoItemCard({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Text(
          todo.icon ?? '📝',
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
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
