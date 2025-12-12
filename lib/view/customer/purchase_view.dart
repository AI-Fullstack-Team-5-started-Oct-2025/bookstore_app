import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/sale/purchase_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//  PurchaseView page
/*
  Create: 12/12/2025 16:24, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: PurchaseView page MUST have arguments from cart.dart

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  //  Property
  late List<PurchaseItem>? purchaseList;

  @override
  void initState() {
    super.initState();
    purchaseList = Get.arguments; //  MUST given by cart.dart
    //  Dummy
    purchaseList = List.filled(1, PurchaseItem(pid: 1, pcid: 1, pcQuantity: 30, pcStatus: '결제 대기'));
  }

  @override
  Widget build(BuildContext context) {
    if (purchaseList == null) {
      return Scaffold(
        appBar: AppBar(title: Text('오류', style: config.rLabel)),
        body: const Center(
          child: Text('구매 내역이 없거나 오류가 있습니다', style: config.rLabel),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.payment),
            Text('결제 하기', style: config.rLabel),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: purchaseList!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  child: Row(
                    children: [
                      Image.asset(
                        'images/Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png', //  MUST be fixed on actual release
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 20),
                      Text('THIS IS DUMMY', style: config.rLabel),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text('구매 수량: ${purchaseList![index].pcQuantity}', style: config.rLabel),  //  MUST be fixed on actual release
                          SizedBox(height: 10),
                          Text('구매 가격: ${purchaseList![index].pid}', style: config.rLabel),  //  MUST be fixed on actual release
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              // 구매 로직
              print("결제하기!");
            },
            child: Text("결제 하기", style: config.rLabel),
          ),
        ),
      ),
    );
  }
}
