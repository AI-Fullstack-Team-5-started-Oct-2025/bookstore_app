import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  //  Property
  late Product dProduct; //  Dummy Product
  late ProductBase dProductBase; //  Dummy ProductBase
  late ProductImage dProductImage; //  Dummy ProductImage
  late Manufacturer dManufacturer;  //  Dummy Manufacturer
  late Product product;
  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  @override
  void initState() {
    super.initState();
    //  FK를 이용한 Product 조립(Product, ProductBase, ProductImage, Manufacturer)
    svInitDB();
  }

  Future<void> svInitDB() async {
    final productDAO = RDAO<Product>(
      dbName: dbName,
      tableName: config.kTableProduct,
      dVersion: dVersion,
      fromMap: Product.fromMap,
    );
    final productbaseDAO = RDAO<ProductBase>(
      dbName: dbName,
      tableName: config.kTableProductBase,
      dVersion: dVersion,
      fromMap: ProductBase.fromMap,
    );
    final productImageDAO = RDAO<ProductImage>(
      dbName: dbName,
      tableName: config.kTableProductImage,
      dVersion: dVersion,
      fromMap: ProductImage.fromMap,
    );
    final manufacturerDAO = RDAO<Manufacturer>(
      dbName: dbName,
      tableName: config.kTableManufacturer,
      dVersion: dVersion,
      fromMap: Manufacturer.fromMap,
    );
    dProductBase = ProductBase(
      pName: 'Dummy',
      pDescription: 'This is Dummy description',
      pGender: 'Male',
      pStatus: 'Null',
      pCategory: 'Dummy Category',
      pModelNumber: 'Hebi.2',
    );
    await productbaseDAO.insertK(dProductBase.toMap());
    dProductImage = ProductImage(pbid: dProductBase.id, imagePath: 'Dummy Image');
    await productImageDAO.insertK(dProductImage.toMap());
    dManufacturer = Manufacturer(mName: 'Nikke');
    await manufacturerDAO.insertK(dManufacturer.toMap());
    dProduct = Product(
      pbid: dProductBase.id,
      mfid: dManufacturer.id,
      color: 'color',
      size: 250,
      basePrice: 10500,
    );
    await productDAO.insertK(dProduct.toMap());
    product = await productDAO.queryK({'id': 1});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('${product.id}')));
  }
}
