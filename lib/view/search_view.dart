import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:bookstore_app/mv/oncrate.dart';
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
  late Manufacturer dManufacturer; //  Dummy Manufacturer

  Product? product;
  List<Product>? productSizes;
  ProductBase? productBase;
  ProductImage? productImage;
  Manufacturer? manufacturer;

  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  @override
  void initState() {
    super.initState();
    //  FK를 이용한 Product 조립(Product, ProductBase, ProductImage, Manufacturer)
    svInitDB();
  }

  Future<void> svInitDB() async {
    await DBCreation.creation(dbName, dVersion);
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
      pColor: 'Black',
      pGender: 'Male',
      pStatus: 'Null',
      pCategory: 'Dummy Category',
      pModelNumber: 'Hebi.2',
    );
    dProductBase.id = await productbaseDAO.insertK(dProductBase.toMap());
    dProductImage = ProductImage(
      pbid: dProductBase.id,
      imagePath:
          '${config.kImageAssetPath}Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
    );
    dProductImage.id = await productImageDAO.insertK(dProductImage.toMap());
    dManufacturer = Manufacturer(mName: 'Nikke');
    dManufacturer.id = await manufacturerDAO.insertK(dManufacturer.toMap());
    dProduct = Product(
      pbid: dProductBase.id,
      mfid: dManufacturer.id,
      size: 250,
      basePrice: 10500,
    );
    dProduct.id = await productDAO.insertK(dProduct.toMap());
    product = (await productDAO.queryK({'id': dProduct.id})).first;
    productBase = (await productbaseDAO.queryK({'id': product!.pbid})).first;
    productSizes = await productDAO.queryK({'pbid': productBase!.id});
    productImage = (await productImageDAO.queryK({
      'pbid': product!.pbid,
    })).first;
    manufacturer = (await manufacturerDAO.queryK({'id': product!.mfid})).first;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (productBase == null || productImage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          productBase!.pName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Center(
              child: Image.asset(
                productImage!.imagePath,
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 280,
              ),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     상품명: ${productBase!.pName}',
                style: config.rLabel,
              ),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     가격: ${config.priceFormatter.format(product!.basePrice)}',
                style: config.rLabel,
              ),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     사이즈', style: config.rLabel),
            ),
            Row(
              children: [
                SizedBox(
                  height: 50, // 높이 지정해야 가로 리스트가 보임
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.sizeOf(context).width, // 또는 Expanded로 감싸기
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: productSizes?.length ?? 0,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final size = productSizes![index].size;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            size.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
