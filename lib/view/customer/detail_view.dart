//  DetailView page
/*
  Create: 10/12/2025 12:42, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    12/12/2025 10:18, 'Point 1, Adjusting Quantity and move to Add cart page', Creator: Chansol Park
    13/12/2025 16:50, 'Point 2, Actual connection to DB', Creator: Chansol Park
    13/12/2025 19:02, 'Modified all', Created by Chansol Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: DetailView page

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DetailView extends StatefulWidget {
  const DetailView({super.key});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  // Data
  Product? product;
  List<Product>? productSizes;
  ProductBase? productBase;
  List<ProductBase>? productColors; // 같은 모델번호의 ProductBase들(=색상 옵션)
  List<String>? pbColors;
  ProductImage? productImage;
  Manufacturer? manufacturer;

  // UI State
  int selectedColorIndex = 0;
  int quantity = 1;
  bool switching = false;

  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  late final RDAO<Product> productDAO;
  late final RDAO<ProductBase> productBaseDAO;
  late final RDAO<ProductImage> productImageDAO;
  late final RDAO<Manufacturer> manufacturerDAO;

  @override
  void initState() {
    super.initState();

    productDAO = RDAO<Product>(
      dbName: dbName,
      tableName: config.kTableProduct,
      dVersion: dVersion,
      fromMap: Product.fromMap,
    );
    productBaseDAO = RDAO<ProductBase>(
      dbName: dbName,
      tableName: config.kTableProductBase,
      dVersion: dVersion,
      fromMap: ProductBase.fromMap,
    );
    productImageDAO = RDAO<ProductImage>(
      dbName: dbName,
      tableName: config.kTableProductImage,
      dVersion: dVersion,
      fromMap: ProductImage.fromMap,
    );
    manufacturerDAO = RDAO<Manufacturer>(
      dbName: dbName,
      tableName: config.kTableManufacturer,
      dVersion: dVersion,
      fromMap: Manufacturer.fromMap,
    );

    svInitDB();
  }

  Future<void> svInitDB() async {
    final int pbidArg = Get.arguments as int;

    // 1) 현재 ProductBase
    productBase = (await productBaseDAO.queryK({'id': pbidArg})).first;

    // 2) 색상 옵션(같은 모델번호)
    productColors = await productBaseDAO.queryK({
      'pModelNumber': productBase!.pModelNumber,
    });
    pbColors = productColors!.map((e) => e.pColor).toList();

    // 3) 초기 선택 인덱스(현재 PB의 색상 위치)
    selectedColorIndex = pbColors!.indexOf(productBase!.pColor);
    if (selectedColorIndex < 0) selectedColorIndex = 0;

    // 4) 초기 화면도 applyColor로 통일
    await _applyColor(productColors![selectedColorIndex], setChipIndex: false);

    setState(() {});
  }

  /// 색상 선택 시: 해당 색상의 ProductBase로 교체하고, 연관(Product/이미지/제조사/사이즈) 재로딩
  Future<void> _applyColor(
    ProductBase newPB, {
    bool setChipIndex = true,
  }) async {
    if (switching) return;

    setState(() => switching = true);

    productBase = newPB;
    final pbid = productBase!.id!;

    // Product들(=사이즈 목록)
    final prodList = await productDAO.queryK({'pbid': pbid});
    productSizes = prodList;
    product = prodList.first; // 대표(첫번째) — 원하면 기준 바꿔줄게

    // 이미지
    productImage = (await productImageDAO.queryK({'pbid': pbid})).first;

    // 제조사
    manufacturer = (await manufacturerDAO.queryK({'id': product!.mfid})).first;

    // Chip 인덱스도 맞추기(옵션)
    if (setChipIndex) {
      final idx = pbColors!.indexOf(productBase!.pColor);
      if (idx >= 0) selectedColorIndex = idx;
    }

    // 수량은 색상 바꾸면 1로 리셋(원하면 유지 가능)
    quantity = 1;

    setState(() => switching = false);
  }

  @override
  Widget build(BuildContext context) {
    if (productBase == null || productImage == null || product == null) {
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지 + 로딩 오버레이
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    productImage!.imagePath,
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: 280,
                    fit: BoxFit.cover,
                  ),
                ),
                if (switching)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x55FFFFFF),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     상품명: ${productBase!.pName}',
                style: config.rLabel,
              ),
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     가격: ${config.priceFormatter.format(product!.basePrice)}',
                style: config.rLabel,
              ),
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     사이즈', style: config.rLabel),
            ),

            const SizedBox(height: 25),
            SizedBox(
              height: 50,
              width: MediaQuery.sizeOf(context).width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
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
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(size.toString(), style: config.rLabel),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     색상', style: config.rLabel),
            ),

            const SizedBox(height: 25),
            Wrap(
              spacing: 12,
              children: List.generate(productColors?.length ?? 0, (index) {
                return ChoiceChip(
                  label: Text(pbColors![index]),
                  selected: selectedColorIndex == index,
                  onSelected: (bool selected) async {
                    if (!selected) return;
                    if (switching) return;

                    // 먼저 선택 UI 반영
                    setState(() => selectedColorIndex = index);

                    // 실제 데이터 갈아끼우기
                    await _applyColor(
                      productColors![index],
                      setChipIndex: false,
                    );
                  },
                  selectedColor: Colors.deepPurple.shade100,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: selectedColorIndex == index
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     수량', style: config.rLabel),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text('$quantity', style: config.rLabel),
                        ),
                        IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade50,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (product == null || productBase == null) return;

                          final box = GetStorage();

                          // 기존 cart 불러오기 (없으면 빈 리스트)
                          final List<dynamic> raw = box.read('cart') ?? [];
                          final List<Map<String, dynamic>> cart = raw
                              .map((e) => Map<String, dynamic>.from(e))
                              .toList();

                          // 지금 담을 아이템(필요한 정보 넉넉히 저장)
                          final item = <String, dynamic>{
                            'productId': product!.id, // Product PK
                            'pbid': product!.pbid, // ProductBase FK
                            'mfid': product!.mfid, // Manufacturer FK
                            'name': productBase!.pName, // 표시용
                            'color': productBase!.pColor, // 표시/구매옵션
                            'size': product!.size, // 표시/구매옵션
                            'unitPrice': product!
                                .basePrice, // 가격 (Product에 있음) :contentReference[oaicite:0]{index=0}
                            'quantity': quantity ?? 1,
                            'imagePath': productImage?.imagePath, // 표시용
                          };

                          // 같은 상품(예: productId 기준) 있으면 수량 누적
                          final idx = cart.indexWhere(
                            (e) => e['productId'] == item['productId'],
                          );
                          if (idx >= 0) {
                            cart[idx]['quantity'] =
                                (cart[idx]['quantity'] as int) +
                                (item['quantity'] as int);
                          } else {
                            cart.add(item);
                          }

                          await box.write('cart', cart);

                          Get.snackbar(
                            '장바구니',
                            '담겼음!',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Text('Add Cart', style: config.rLabel),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              print("구매하기!");
            },
            child: Text("구매하기", style: config.rLabel),
          ),
        ),
      ),
    );
  }
}
