import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/db_setting.dart';
import 'package:bookstore_app/mv/oncreate.dart';

import 'package:bookstore_app/view/customer/address_payment_view.dart';
import 'package:bookstore_app/view/customer/cart.dart';
import 'package:bookstore_app/view/customer/detail_view.dart';
import 'package:bookstore_app/view/customer/purchase_view.dart';
import 'package:bookstore_app/view/customer/search_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'view/cheng/screens/auth/login_view.dart';

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
    
  // GetStorage 초기화 (get_storage 사용 전 필수)
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  final dbPath = await getDatabasesPath();

  final path = join(dbPath, '${config.kDBName}${config.kDBFileExt}');
  await deleteDatabase(path);
  await DBCreation.creation(dbName, dVersion);

  DbSetting dbSetting = DbSetting();
  await dbSetting.svInitDB();
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

  void _changedSettings(ThemeMode inputThemeMode, Color inputColorScheme) {
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
      getPages: [
        GetPage(name: '/', page: () => LoginView(),),
        GetPage(name: '/cart', page: () => Cart(),),
        GetPage(name: '/searchview', page: () => SearchView(),),
        GetPage(name: '/detailview', page: () => DetailView(),),
        GetPage(name: '/purchaseview', page: () => PurchaseView(),),
        // GetPage(name: '/returnview', page: () => ReturnView(),),
        GetPage(name: '/address-payment', page: () => AddressPaymentView()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
