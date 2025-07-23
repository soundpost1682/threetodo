import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';
import '../../core/utils/logger.dart';

class TodoDatabase {
  static final TodoDatabase instance = TodoDatabase._init();
  static Database? _database;

  TodoDatabase._init();

  Future<Database> get database async {
    AppLogger.debug('Getting database instance...');
    if (_database != null) {
      AppLogger.debug('Returning existing database instance');
      return _database!;
    }

    AppLogger.info('Initializing new database...');
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'todos.db');
      AppLogger.debug('Database path: $path');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          AppLogger.info('Creating new database...');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS todos(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              category TEXT NOT NULL,
              icon TEXT,
              date TEXT NOT NULL,
              isCompleted INTEGER NOT NULL
            )
          ''');
          AppLogger.info('Database created successfully');
        },
        onOpen: (db) async {
          AppLogger.info('Database opened successfully');
        },
      );
    } catch (e) {
      AppLogger.error('Database initialization error', e);
      rethrow;
    }
  }

  // 할 일 추가
  Future<Todo> create(Todo todo) async {
    try {
      final db = await database;
      final id = await db.insert('todos', todo.toMap());
      AppLogger.debug('Created todo with id: $id');
      return todo.copyWith(id: id);
    } catch (e) {
      AppLogger.error('Create todo error', e);
      rethrow;
    }
  }

  // 특정 날짜의 할 일 목록 조회
  Future<List<Todo>> getTodosByDate(DateTime date) async {
    try {
      final db = await database;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await db.query(
        'todos',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      );

      AppLogger.debug(
          'Found ${result.length} todos for date: ${startOfDay.toString()}');
      return result.map((map) => Todo.fromMap(map)).toList();
    } catch (e) {
      AppLogger.error('Get todos error', e);
      return [];
    }
  }

  // 할 일 수정
  Future<int> update(Todo todo) async {
    try {
      final db = await database;
      return db.update(
        'todos',
        todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      AppLogger.error('Update todo error', e);
      return 0;
    }
  }

  // 할 일 삭제
  Future<int> delete(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.error('Delete todo error', e);
      return 0;
    }
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.debug('Database closed');
    }
  }
}
