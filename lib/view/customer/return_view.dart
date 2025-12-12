import 'package:bookstore_app/config.dart' as config;
import 'package:flutter/material.dart';

//  Return page
/*
  Create: 12/12/2025 12:1, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Return page MUST have lists of returning Products

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class ReturnView extends StatefulWidget {
  const ReturnView({super.key});

  @override
  State<ReturnView> createState() => _ReturnViewState();
}

class _ReturnViewState extends State<ReturnView> {
  // 더미 데이터
  final List<String> _imagePaths = [
    'images/Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png',
    'images/Nike_Air_1/Nike_Air_1_Black_01.avif',
    'images/Nike_Pegasus/Nike_Pegasus_Black_01.avif',
  ];

  final List<String> _productNames = ['Nikke', 'Hebi.', 'Restitutor'];

  /// 상태 문자열 (읽기 전용)
  static const List<String> _allowedStatus = ['신청', '처리중', '완료'];

  /// 각 상품의 현재 상태
  late List<String> _statusList;

  @override
  void initState() {
    super.initState();
    _statusList = List<String>.filled(_productNames.length, _allowedStatus[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('반품 하기', style: config.rLabel),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _productNames.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          _imagePaths[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        // 상품명
                        Expanded(
                          child: Text(
                            _productNames[index],
                            style: config.rLabel,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 🔥 상태 읽기 전용 Text
                        Text(
                          _statusList[index],
                          style: config.rLabel,
                        ),
                      ],
                    ),
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
              debugPrint('반품 상태: $_statusList');
            },
            child: Text(
              '반품 상태 저장',
              style: config.rLabel,
            ),
          ),
        ),
      ),
    );
  }
}