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
  late Product dProduct;  //  Dummy
  late Product product; //  Get.arguments?
  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final String tableName = config.kTableProduct;
  final int dVersion = config.kVersion;

  @override
  void initState() {
    super.initState();
    dProduct = Product(
      pbid: 1,
      mfid: 1,
      color: 'color',
      size: 250,
      basePrice: 10500,
    );
    svInitDB();
  }

  Future<void> svInitDB() async {
    final productDAO = RDAO<Product>(
      dbName: dbName,
      tableName: tableName,
      dVersion: dVersion,
      fromMap: Product.fromMap,
    );
    await productDAO.insertK(dProduct.toMap()); //  Dummy
    await productDAO.updateK(dProduct.toMap()); //  Dummy
    product = await productDAO.queryK({'id':1, 'pbid':1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('${product.id}')));
  }
}
