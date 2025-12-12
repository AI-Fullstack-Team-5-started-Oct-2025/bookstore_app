// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../config.dart' as config;

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Sub directories
import '../../widgets/customer/customer_return_card.dart';

// Local imports - Screens
import 'return_detail_view.dart';

/// 고객용 수령 완료 목록 화면
/// 모바일 세로 화면에 최적화된 수령 완료 목록 화면입니다.
/// 검색 필터와 수령 완료 주문 카드 리스트를 표시하며, 카드를 탭하면 상세 페이지로 이동합니다.
class ReturnListView extends StatefulWidget {
  const ReturnListView({super.key});

  @override
  State<ReturnListView> createState() => _ReturnListViewState();
}

class _ReturnListViewState extends State<ReturnListView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 임시 수령 완료 목록 데이터
  /// TODO: 나중에 DB에서 실제 데이터를 가져오도록 수정 필요
  /// 수령 완료(픽업 완료)된 주문만 필터링하여 표시해야 함
  /// 현재 로그인한 사용자의 수령 완료 주문만 표시해야 함
  final List<Map<String, dynamic>> _tempCompletedOrders = [
    {
      'orderId': 'ORD001',
      'orderDate': '2024-12-01',
    },
    {
      'orderId': 'ORD002',
      'orderDate': '2024-12-02',
    },
    {
      'orderId': 'ORD003',
      'orderDate': '2024-12-03',
    },
  ];

  @override
  void initState() {
    super.initState();
    // TODO: 로그인한 사용자의 수령 완료 주문 목록을 DB에서 가져오기
    // 수령 완료(픽업 완료) 상태인 주문만 조회해야 함
    // 현재 로그인한 사용자 정보: UserStorage.getUser()
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어에 따라 필터링된 수령 완료 목록을 반환하는 getter
  /// 검색어가 비어있으면 전체 목록을 반환하고,
  /// 검색어가 있으면 주문 ID에 검색어가 포함된 주문만 필터링하여 반환합니다.
  List<Map<String, dynamic>> get _filteredCompletedOrders {
    final searchText = _searchController.text.toLowerCase();
    // 검색어가 없으면 전체 목록 반환
    if (searchText.isEmpty) {
      return _tempCompletedOrders;
    }
    // 검색어가 있으면 주문 ID로 필터링
    return _tempCompletedOrders.where((order) {
      return order['orderId'].toString().toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: CustomAppBar(
        title: '수령 완료 목록',
        centerTitle: true,
        titleTextStyle: config.rLabel,
        backgroundColor: const Color(0xFFD9D9D9),
        foregroundColor: Colors.black,
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

                // 수령 완료 목록 제목
                CustomText(
                  '수령 완료 목록',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 수령 완료 목록 리스트 표시
                // 수령 완료 주문이 없으면 안내 메시지 표시, 있으면 주문 카드 리스트 표시
                if (_filteredCompletedOrders.isEmpty)
                  Center(
                    child: CustomPadding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: CustomText(
                        '수령 완료 내역이 없습니다.',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  // 각 수령 완료 주문을 CustomerReturnCard로 표시
                  ..._filteredCompletedOrders.map((order) {
                    return GestureDetector(
                      onTap: () {
                        // 카드 클릭 시 상세 페이지로 이동 (arguments로 orderId 전달)
                        Get.to(
                          () => ReturnDetailView(orderId: order['orderId'] as String),
                        );
                      },
                      child: CustomerReturnCard(
                        orderId: order['orderId'] as String,
                        orderDate: order['orderDate'] as String?,
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

