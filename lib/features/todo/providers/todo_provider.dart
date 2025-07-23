import 'package:flutter/foundation.dart';
import '../../../data/models/todo.dart';
import '../../../data/database/todo_database.dart';
import '../../../core/utils/logger.dart';

class TodoProvider with ChangeNotifier {
  final _db = TodoDatabase.instance;
  List<Todo> _todos = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  // 게터
  List<Todo> get todos => _todos;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // 오늘의 할 일 개수 제한
  static const int maxDailyTodos = 3;

  TodoProvider() {
    AppLogger.debug('TodoProvider created');
    initialize();
  }

  // 초기화 메서드
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      AppLogger.debug('Already initialized or loading');
      return;
    }

    AppLogger.info('Starting initialization');
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      // 데이터베이스 연결 확인
      await _db.database;
      AppLogger.debug('Database connected');

      // 오늘의 할 일 로드
      final today = DateTime.now();
      _selectedDate = DateTime(today.year, today.month, today.day);

      _todos = await _db.getTodosByDate(_selectedDate);
      AppLogger.info('Initial todos loaded: ${_todos.length}');

      _isInitialized = true;
      _error = null;
    } catch (e) {
      AppLogger.error('TodoProvider initialization error', e);
      _error = '초기화 중 오류가 발생했습니다';
      _todos = [];
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
      AppLogger.debug('Initialization completed. Success: $_isInitialized');
    }
  }

  // 선택된 날짜의 할 일 목록 로드
  Future<void> loadTodos([DateTime? date]) async {
    if (_isLoading) return;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final targetDate = date ?? _selectedDate;
      _selectedDate =
          DateTime(targetDate.year, targetDate.month, targetDate.day);

      _todos = await _db.getTodosByDate(_selectedDate);
      AppLogger.debug(
          'Loaded ${_todos.length} todos for date ${_selectedDate.toString()}');
    } catch (e) {
      AppLogger.error('Load todos error', e);
      _error = '할 일을 불러오는 중 오류가 발생했습니다';
      _todos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 할 일 추가
  Future<bool> addTodo(Todo todo) async {
    try {
      _error = null;
      // 날짜 정보 정규화
      final normalizedDate =
          DateTime(todo.date.year, todo.date.month, todo.date.day);
      final normalizedToday = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);

      // 오늘 날짜의 할 일인 경우 개수 제한 체크
      if (normalizedDate.isAtSameMomentAs(normalizedToday)) {
        final todayTodos = await _db.getTodosByDate(normalizedToday);
        if (todayTodos.length >= maxDailyTodos) {
          _error = '오늘은 더 이상 할 일을 추가할 수 없습니다';
          notifyListeners();
          return false;
        }
      }

      final newTodo = await _db.create(todo);
      if (normalizedDate.isAtSameMomentAs(_selectedDate)) {
        _todos.add(newTodo);
        notifyListeners();
      }
      return true;
    } catch (e) {
      AppLogger.error('Add todo error', e);
      _error = '할 일을 추가하는 중 오류가 발생했습니다';
      notifyListeners();
      return false;
    }
  }

  // 할 일 상태 토글 (완료/미완료)
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      _error = null;
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
      await _db.update(updatedTodo);

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Toggle todo status error', e);
      _error = '상태를 변경하는 중 오류가 발생했습니다';
      notifyListeners();
    }
  }

  // 할 일 수정
  Future<void> updateTodo(Todo todo) async {
    try {
      _error = null;
      await _db.update(todo);

      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Update todo error', e);
      _error = '할 일을 수정하는 중 오류가 발생했습니다';
      notifyListeners();
    }
  }

  // 할 일 삭제
  Future<void> deleteTodo(int id) async {
    try {
      _error = null;
      await _db.delete(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Delete todo error', e);
      _error = '할 일을 삭제하는 중 오류가 발생했습니다';
      notifyListeners();
    }
  }

  // 선택된 날짜 변경
  void changeSelectedDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!normalizedDate.isAtSameMomentAs(_selectedDate)) {
      loadTodos(normalizedDate);
    }
  }

  // 오늘의 할 일 추가 가능 여부 확인
  Future<bool> canAddTodoForToday() async {
    try {
      _error = null;
      final today = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final todayTodos = await _db.getTodosByDate(today);
      return todayTodos.length < maxDailyTodos;
    } catch (e) {
      AppLogger.error('Check can add todo error', e);
      _error = '할 일 추가 가능 여부를 확인하는 중 오류가 발생했습니다';
      notifyListeners();
      return false;
    }
  }
}
