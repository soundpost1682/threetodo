import 'package:flutter/foundation.dart';
import '../../../data/models/todo.dart';
import '../../../data/database/todo_database.dart';

class TodoProvider with ChangeNotifier {
  final _db = TodoDatabase.instance;
  List<Todo> _todos = [];
  DateTime _selectedDate = DateTime.now();

  // 게터
  List<Todo> get todos => _todos;
  DateTime get selectedDate => _selectedDate;

  // 오늘의 할 일 개수 제한
  static const int maxDailyTodos = 3;

  // 선택된 날짜의 할 일 목록 로드
  Future<void> loadTodos([DateTime? date]) async {
    _selectedDate = date ?? _selectedDate;
    _todos = await _db.getTodosByDate(_selectedDate);
    notifyListeners();
  }

  // 할 일 추가
  Future<bool> addTodo(Todo todo) async {
    // 오늘 날짜의 할 일인 경우 개수 제한 체크
    if (todo.date.year == DateTime.now().year &&
        todo.date.month == DateTime.now().month &&
        todo.date.day == DateTime.now().day) {
      final todayTodos = await _db.getTodosByDate(DateTime.now());
      if (todayTodos.length >= maxDailyTodos) {
        return false; // 할 일 추가 실패
      }
    }

    final newTodo = await _db.create(todo);
    _todos.add(newTodo);
    notifyListeners();
    return true; // 할 일 추가 성공
  }

  // 할 일 상태 토글 (완료/미완료)
  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    await _db.update(updatedTodo);

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      notifyListeners();
    }
  }

  // 할 일 수정
  Future<void> updateTodo(Todo todo) async {
    await _db.update(todo);

    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      notifyListeners();
    }
  }

  // 할 일 삭제
  Future<void> deleteTodo(int id) async {
    await _db.delete(id);
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  // 선택된 날짜 변경
  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    loadTodos();
  }

  // 오늘의 할 일 추가 가능 여부 확인
  Future<bool> canAddTodoForToday() async {
    final todayTodos = await _db.getTodosByDate(DateTime.now());
    return todayTodos.length < maxDailyTodos;
  }
}
