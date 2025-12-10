import 'package:bookstore_app/config.dart';
import 'package:bookstore_app/view/login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => Login())],
  // routes: [GoRoute(path: '/settings', builder: (context, state) => Settings(onChangeTheme: _changeTheme))],
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbPath = await getDatabasesPath();
  final path = join(dbPath, '$dbName.db');
  await deleteDatabase(path);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; //  시스템에서 설정한 색상으로 초기화를 한다.
  Color seedColor = Colors.deepPurple;

  _changeTheme(ThemeMode inputThemeMode, Color inputColorScheme) {
    _themeMode = inputThemeMode;
    seedColor = inputColorScheme;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: router,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: seedColor,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: seedColor,
      ),
    );
  }
}
