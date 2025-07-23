import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/todo/providers/todo_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'data/database/todo_database.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 데이터베이스 초기화
  try {
    AppLogger.info('Starting app initialization');
    final db = TodoDatabase.instance;
    await db.database;
    AppLogger.info('Database initialized successfully');
  } catch (e) {
    AppLogger.error('Database initialization error', e);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            AppLogger.debug('Creating TodoProvider');
            return TodoProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Building MyApp');
    return MaterialApp(
      title: 'Three TODOs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
