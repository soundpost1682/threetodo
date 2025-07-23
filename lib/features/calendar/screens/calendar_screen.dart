import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../todo/providers/todo_provider.dart';
import '../../../data/models/todo.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static final DateTime firstDay = DateTime.utc(2024, 1, 1);
  static final DateTime lastDay = DateTime.utc(2024, 12, 31);

  DateTime getInitialFocusedDay() {
    final now = DateTime.now();
    if (now.isBefore(firstDay)) return firstDay;
    if (now.isAfter(lastDay)) return lastDay;
    return now;
  }

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = getInitialFocusedDay();
    _selectedDay =
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    Future.microtask(
        () => context.read<TodoProvider>().loadTodos(_selectedDay!));
  }

  void _setFocusedDay(DateTime day) {
    if (day.isBefore(firstDay)) {
      _focusedDay = firstDay;
    } else if (day.isAfter(lastDay)) {
      _focusedDay = lastDay;
    } else {
      _focusedDay = day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return Column(
            children: [
              TableCalendar<Todo>(
                firstDay: firstDay,
                lastDay: lastDay,
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _setFocusedDay(focusedDay);
                    });
                    context.read<TodoProvider>().loadTodos(selectedDay);
                  }
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _setFocusedDay(focusedDay);
                  });
                  context.read<TodoProvider>().loadEventsForMonth(_focusedDay);
                },
                eventLoader: (day) => todoProvider.getTodosForDay(day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 0.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.deepPurple,
                              ),
                            ),
                            if (events.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Text(
                                  '${events.length}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.deepPurple),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return null;
                  },
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: todoProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (todoProvider.todos.isEmpty
                        ? const Center(child: Text('이 날의 할 일이 없습니다'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: todoProvider.todos.length,
                            itemBuilder: (context, index) {
                              final todo = todoProvider.todos[index];
                              return CalendarTodoItem(todo: todo);
                            },
                          )),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CalendarTodoItem extends StatelessWidget {
  final Todo todo;

  const CalendarTodoItem({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            todo.icon ?? '📝',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(todo.category),
        trailing: Icon(
          todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
          color: todo.isCompleted ? Colors.green : Colors.grey,
        ),
        onTap: () {
          context.read<TodoProvider>().toggleTodoStatus(todo);
        },
      ),
    );
  }
}
