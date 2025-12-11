import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/view/cheng/login_screen.dart';
import 'package:bookstore_app/view/login.dart';
import 'package:bookstore_app/view/search_view.dart';
import 'package:bookstore_app/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// final GoRouter router = GoRouter(

//   initialLocation: config.routeLogin,
//   routes: [
//     GoRoute(path: config.routeLogin, builder: (context, state) => SearchView()),
//     GoRoute(
//       path: config.routeSettings,
//       builder: (context, state) => SettingPage(),
//     ),
//   ],
// );
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbPath = await getDatabasesPath();

  final path = join(dbPath, '${config.kDBName}${config.kDBFileExt}');
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

  Color _seedColor = Colors.deepPurple;

  _changedSettings(ThemeMode inputThemeMode, Color inputColorScheme) {
    _themeMode = inputThemeMode;
    _seedColor = inputColorScheme;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      // routerConfig: router,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,

        colorSchemeSeed: _seedColor,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: _seedColor,
      ),
      initialRoute: '/',
      getPages: [GetPage(name: '/', page: () => LoginScreen(),)

      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
