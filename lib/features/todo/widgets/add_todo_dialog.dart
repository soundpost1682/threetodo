import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/todo.dart';
import '../providers/todo_provider.dart';

class AddTodoDialog extends StatefulWidget {
  const AddTodoDialog({super.key});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedCategory = '성장';
  String _selectedIcon = '📝';

  final _categories = ['성장', '운동', '공부', '자기관리'];
  final _icons = ['📝', '🌱', '🏃', '📚', '🧘', '💪', '🎯', '✨'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('할 일 추가'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목 입력
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '할 일',
                  hintText: '할 일을 입력하세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '할 일을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 카테고리 선택
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 아이콘 선택
              Wrap(
                spacing: 8,
                children: _icons.map((icon) {
                  return IconChoice(
                    icon: icon,
                    isSelected: _selectedIcon == icon,
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(onPressed: _submitForm, child: const Text('추가')),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final todo = Todo(
        title: _titleController.text,
        category: _selectedCategory,
        icon: _selectedIcon,
        date: DateTime.now(),
      );

      final success = await context.read<TodoProvider>().addTodo(todo);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('오늘은 더 이상 할 일을 추가할 수 없습니다.')),
          );
        }
      }
    }
  }
}

class IconChoice extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const IconChoice({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
