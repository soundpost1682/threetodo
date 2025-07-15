import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Three TODOs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // 다국어 지원 설정
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'), // 한국어
        Locale('en'), // 영어
      ],

      // 임시 홈 화면 (다음 단계에서 실제 화면으로 교체될 예정)
      home: Scaffold(
        appBar: AppBar(title: const Text('Three TODOs')),
        body: const Center(child: Text('Welcome to Three TODOs')),
      ),
    );
  }
}
