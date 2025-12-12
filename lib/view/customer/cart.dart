import 'package:bookstore_app/config.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:flutter/material.dart';

//  Cart page
/*
  Create: 12/12/2025 10:46, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Cart page MUST have lists of Products

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  //  Property
  //  Dummy
  List<String> dImagePaths = [
    'images/Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
    'images/Nike_Air_1/Nike_Air_1_Black_01.avif',
    'images/Nike_Pegasus/Nike_Pegasus_Black_01.avif',
  ];
  List<String> dProductNames = ['Nikke', 'Hebi.', 'Restitutor'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined),
            SizedBox(width: 20),
            Text('  장바구니', style: rLabel),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dProductNames.length, //  NEED to fix on actual release
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  child: Row(
                    children: [
                      Image.asset(
                        dImagePaths[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 20),
                      Text(dProductNames[index], style: config.rLabel,),
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
              print("구매하기!");
            },
            child: Text(
              "구매하기",
              style: config.rLabel,
            ),
          ),
        ),
      ),
    );
  }
}
