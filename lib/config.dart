//  Configuration of the App
/*
  Create: 10/12/2025 16:43, Creator: Chansol, Park
  Update log: 
    DUMMY 9/29/2025 09:53, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Desc: Config for dbName, version, etc.
*/

import 'package:flutter/material.dart';

//  DB
//  For use
//  '${config.kDBName}${config.kDBFileExt}';
const String kDBName = 'bookstore';
const String kDBFileExt = '.db';
const int kVersion = 1;

//  Screen Datas
const seedColorDefault = Colors.deepPurple;
const defaultThemeMode = ThemeMode.system;

//  Paths
const String kImageAssetPath = 'images/';
const String kIconAssetPath = 'icons/';

//  DB Dummies
const int kDefaultUserId = -1;  //  UserID befor login
const String kDefaultProductImage = '${kImageAssetPath}default.png';  //  Default image for ProductBase

//  Formats
const String dateFormat = 'yyyy-MM-dd';
const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
const int minPasswordLength = 8;
const int maxPasswordLength = 20;

final RegExp emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
);
const int kDefaultPageSize = 20;  //  Pagenation
const Duration kApiTimeout = Duration(seconds: 10); //  App timeout
const Duration kLoginDelay = Duration(seconds: 2);  //  Delay when pressing Login button

//  Features
const bool kEnableSaleFeature = true;
const bool kEnableStockAutoRequest = true;
const bool kUseLocalDBOnly = true;

//  Tables
const String kTableCustomer = 'Customer';
const String kTableProductImage = 'ProductImage';
const String kTableProductBase = 'ProductBase';
const String kTableManufacturer = 'Manufacturer';
const String kTableProduct = 'Product';
const String tTableEmployee = 'Employee';


//  Routes
const String routeLogin = '/';
const String routeSettings = '/settings';
const String routeProductDetail = '/product';
const String routeCart = '/cart';
const String routePurchaseHistory = '/history';
