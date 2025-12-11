import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/product/product.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  //  Property
  late Product product;
  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final String tableName = config.kTableProduct;
  final int dVersion = config.kVersion;

  @override
  void initState() {
    super.initState();
    svDummy();
  }

  Future<void> svDummy() async{
    await RDAO(dbName: dbName, tableName: tableName, dVersion: dVersion, fromMap: (<Product>) {
      
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('data'),),);
  }
}