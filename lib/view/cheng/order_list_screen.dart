import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config.dart' as config;
import 'custom/custom.dart';
import 'customer_sub_dir/customer_order_card.dart';
import 'order_detail_screen.dart';

/// 고객용 주문 목록 화면
/// 모바일 세로 화면에 최적화된 주문 목록 화면입니다.
/// 검색 필터와 주문 카드 리스트를 표시하며, 카드를 탭하면 상세 페이지로 이동합니다.
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 임시 주문 목록 데이터
  /// TODO: 나중에 DB에서 실제 데이터를 가져오도록 수정 필요
  /// 현재 로그인한 사용자의 주문만 필터링하여 표시해야 함
  final List<Map<String, dynamic>> _tempOrders = [
    {
      'orderId': 'ORD001',
      'orderStatus': '대기중',
      'orderDate': '2024-12-01',
      'totalPrice': 120000,
    },
    {
      'orderId': 'ORD002',
      'orderStatus': '준비완료',
      'orderDate': '2024-12-02',
      'totalPrice': 150000,
    },
    {
      'orderId': 'ORD003',
      'orderStatus': '픽업완료',
      'orderDate': '2024-12-03',
      'totalPrice': 200000,
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: 로그인한 사용자의 주문 목록을 DB에서 가져오기
    // 현재 로그인한 사용자 정보: UserStorage.getUser()
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어에 따라 필터링된 주문 목록을 반환하는 getter
  /// 검색어가 비어있으면 전체 목록을 반환하고,
  /// 검색어가 있으면 주문 ID에 검색어가 포함된 주문만 필터링하여 반환합니다.
  List<Map<String, dynamic>> get _filteredOrders {
    final searchText = _searchController.text.toLowerCase();
    // 검색어가 없으면 전체 목록 반환
    if (searchText.isEmpty) {
      return _tempOrders;
    }
    // 검색어가 있으면 주문 ID로 필터링
    return _tempOrders.where((order) {
      return order['orderId'].toString().toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '수령 목록',
        centerTitle: true,
        titleTextStyle: config.rLabel,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: const EdgeInsets.all(16),
            child: CustomColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                // 검색 필터
                CustomTextField(
                  controller: _searchController,
                  hintText: '주문번호로 검색',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (_) => setState(() {}),
                ),

                // 주문 목록 제목
                CustomText(
                  '주문 목록',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 주문 목록 리스트 표시
                // 주문이 없으면 안내 메시지 표시, 있으면 주문 카드 리스트 표시
                if (_filteredOrders.isEmpty)
                  Center(
                    child: CustomPadding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: CustomText(
                        '주문 내역이 없습니다.',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  // 각 주문을 CustomerOrderCard로 표시
                  ..._filteredOrders.map((order) {
                    return GestureDetector(
                      onTap: () {
                        // 카드 클릭 시 주문 상세 페이지로 이동 (arguments로 orderId 전달)
                        Get.to(
                          () => OrderDetailScreen(orderId: order['orderId'] as String),
                        );
                      },
                      child: CustomerOrderCard(
                        orderId: order['orderId'] as String,
                        orderStatus: order['orderStatus'] as String,
                        orderDate: order['orderDate'] as String?,
                        totalPrice: order['totalPrice'] as int?,
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

