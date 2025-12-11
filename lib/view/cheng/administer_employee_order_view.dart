import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom/custom.dart';

// 관리자/직원 주문 관리 화면
// 태블릿에서 가로 모드로 강제 표시

class AdministerEmployeeOrderView extends StatefulWidget {
  const AdministerEmployeeOrderView({super.key});

  @override
  State<AdministerEmployeeOrderView> createState() =>
      _AdministerEmployeeOrderViewState();
}

class _AdministerEmployeeOrderViewState
    extends State<AdministerEmployeeOrderView> {
  // 검색 필터 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // 선택된 주문 ID (null이면 데이터 없음 표시)
  String? _selectedOrderId;

  // 임시 주문 목록 데이터 (나중에 DB에서 가져올 예정)
  final List<Map<String, dynamic>> _tempOrders = [
    {'orderId': 'ORD001', 'customerName': '홍길동', 'orderStatus': '대기중'},
    {'orderId': 'ORD002', 'customerName': '김철수', 'orderStatus': '준비완료'},
    {'orderId': 'ORD003', 'customerName': '이영희', 'orderStatus': '대기중'},
  ];

  // 필터링된 주문 목록
  List<Map<String, dynamic>> get _filteredOrders {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _tempOrders;
    }
    return _tempOrders.where((order) {
      return order['orderId'].toString().toLowerCase().contains(searchText) ||
          order['customerName'].toString().toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 태블릿이면 가로 모드로 고정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isTablet(context)) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // 페이지 나갈 때 모든 방향 허용으로 복구
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '관리자',
        centerTitle: true,
        drawerIcon: Icons.menu,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: CustomRow(
          spacing: 0,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 좌측 1/3: 주문 목록
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: CustomPadding(
                  padding: const EdgeInsets.all(16),
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      // 검색 필터
                      CustomTextField(
                        controller: _searchController,
                        hintText: '고객명/주문번호 찾기',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: (_) => setState(() {}),
                      ),

                      // 주문 목록 제목
                      CustomText(
                        '주문 목록',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      // 주문 목록 리스트
                      _filteredOrders.isEmpty
                          ? Center(
                              child: CustomText(
                                '주문이 없습니다.',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredOrders.length,
                              itemBuilder: (context, index) {
                                final order = _filteredOrders[index];
                                return _OrderCard(
                                  orderId: order['orderId'],
                                  customerName: order['customerName'],
                                  orderStatus: order['orderStatus'],
                                  isSelected:
                                      _selectedOrderId == order['orderId'],
                                  onTap: () {
                                    setState(() {
                                      _selectedOrderId = order['orderId'];
                                    });
                                  },
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),

            // 세로 디바이더
            const VerticalDivider(width: 1, thickness: 1, color: Colors.grey),

            // 우측 2/3: 주문자 상세 정보
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: CustomPadding(
                  padding: const EdgeInsets.all(16),
                  child: _selectedOrderId == null
                      ? Center(
                          child: CustomText(
                            '데이터 없음',
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _OrderDetailView(orderId: _selectedOrderId!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----Function Start----

  // 태블릿 여부 확인
  bool _isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    // 600px 이상이면 태블릿으로 간주
    return shortestSide >= 600;
  }

  // 드로워 메뉴 생성
  Widget _buildDrawer() {
    return CustomDrawer(
      items: [
        DrawerItem(
          label: '주문 관리',
          icon: Icons.shopping_cart,
          selected: true,
          onTap: () {
            Navigator.pop(context);
          },
        ),
        // TODO: 다른 메뉴 항목들 추가
      ],
    );
  }

  //----Function End----
}

// 주문 카드 위젯
class _OrderCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String orderStatus;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderCard({
    required this.orderId,
    required this.customerName,
    required this.orderStatus,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomCard(
        color: isSelected ? Colors.blue.shade50 : null,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        child: CustomColumn(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(orderId, fontSize: 14, fontWeight: FontWeight.bold),
                CustomText(
                  orderStatus,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
            CustomText(
              customerName,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}

// 주문 상세 정보 뷰
class _OrderDetailView extends StatelessWidget {
  final String orderId;

  const _OrderDetailView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    // TODO: DB에서 주문 상세 정보 가져오기
    // 임시 데이터
    final customerInfo = {
      'name': '홍길동',
      'phone': '010-1234-5678',
      'email': 'hong@example.com',
    };

    final orderItems = [
      {
        'productName': '나이키 에어맥스',
        'size': '265',
        'color': '블랙',
        'quantity': 1,
        'price': 120000,
      },
      {
        'productName': '아디다스 스탠스미스',
        'size': '270',
        'color': '화이트',
        'quantity': 2,
        'price': 150000,
      },
    ];

    final totalPrice = orderItems.fold<int>(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
    );

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // 주문자 상세 정보 카드
        CustomCard(
          child: CustomColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              CustomText(
                '주문자 상세 정보',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                '이름 : ${customerInfo['name']}',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              CustomText(
                '연락처: ${customerInfo['phone']}',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              CustomText(
                '이메일: ${customerInfo['email']}',
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ],
          ),
        ),

        // 주문 상품들
        CustomText('주문 상품들', fontSize: 18, fontWeight: FontWeight.bold),

        // 주문 상품 리스트
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orderItems.length,
          itemBuilder: (context, index) {
            final item = orderItems[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              child: CustomRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomText(
                      item['productName'] as String,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      '${item['size']}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      item['color'] as String,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: CustomText(
                      '${item['quantity']}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: CustomText(
                      '${_formatPrice(item['price'] as int)}원',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 총 가격
        CustomRow(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              '총 가격: ${_formatPrice(totalPrice)}원',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        // 픽업 완료 버튼
        CustomButton(
          btnText: '픽업 완료',
          buttonType: ButtonType.elevated,
          onCallBack: () {
            // TODO: 픽업 완료 함수 호출
            print('픽업 완료: $orderId');
          },
          minimumSize: const Size(double.infinity, 50),
        ),
      ],
    );
  }

  // 가격 포맷팅 (천 단위 콤마)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
