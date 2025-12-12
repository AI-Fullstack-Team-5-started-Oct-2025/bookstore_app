import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'custom/custom.dart';
import 'admin_employee_order_view.dart';
import 'employee_sub_dir/admin_drawer.dart';
import 'employee_sub_dir/return_order_card.dart';
import 'employee_sub_dir/return_order_detail_view.dart';
import 'employee_sub_dir/admin_tablet_utils.dart';
import 'employee_sub_dir/admin_storage.dart';
import 'admin_profile_edit.dart';

/// 관리자/직원 반품 관리 화면
/// 태블릿에서 가로 모드로 강제 표시되는 반품 관리 화면입니다.
/// 좌측에 반품 주문 목록을 표시하고, 우측에 선택된 반품 주문의 상세 정보를 표시합니다.

class AdministerEmployeeReturnOrderView extends StatefulWidget {
  const AdministerEmployeeReturnOrderView({super.key});

  @override
  State<AdministerEmployeeReturnOrderView> createState() =>
      _AdministerEmployeeReturnOrderViewState();
}

class _AdministerEmployeeReturnOrderViewState
    extends State<AdministerEmployeeReturnOrderView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 현재 선택된 반품 주문 ID
  /// null이면 우측에 "데이터 없음" 메시지 표시
  String? _selectedOrderId;

  /// 임시 반품 주문 목록 데이터
  /// TODO: 나중에 DB에서 실제 데이터를 가져오도록 수정 필요
  final List<Map<String, dynamic>> _tempOrders = [
    {'orderId': 'ORD001', 'customerName': '홍길동', 'orderStatus': '반품요청'},
    {'orderId': 'ORD002', 'customerName': '김철수', 'orderStatus': '반품처리중'},
    {'orderId': 'ORD003', 'customerName': '이영희', 'orderStatus': '반품요청'},
  ];

  /// 검색어에 따라 필터링된 반품 주문 목록을 반환하는 getter
  /// 검색어가 비어있으면 전체 목록을 반환하고,
  /// 검색어가 있으면 주문 ID 또는 고객명에 검색어가 포함된 반품 주문만 필터링하여 반환합니다.
  List<Map<String, dynamic>> get _filteredOrders {
    final searchText = _searchController.text.toLowerCase();
    // 검색어가 없으면 전체 목록 반환
    if (searchText.isEmpty) {
      return _tempOrders;
    }
    // 검색어가 있으면 주문 ID 또는 고객명으로 필터링
    return _tempOrders.where((order) {
      return order['orderId'].toString().toLowerCase().contains(searchText) ||
          order['customerName'].toString().toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // 페이지 진입 시 태블릿이면 가로 모드로 고정
    lockTabletLandscape(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    // 페이지 나갈 때 모든 방향 허용으로 복구
    unlockAllOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '반품 관리',
        centerTitle: true,
        drawerIcon: Icons.menu,
        toolbarHeight: 48, // 앱바 높이 최소화
      ),
      drawer: AdminDrawer(
        currentMenu: AdminMenuType.returnManagement,
        userName: AdminStorage.getAdminName(),
        userRole: AdminStorage.getAdminRole(),
        menuItems: [
          AdminDrawerMenuItem(
            label: '주문 관리',
            icon: Icons.shopping_cart,
            menuType: AdminMenuType.orderManagement,
            onTap: () {
              Get.off(
                () => const AdministerEmployeeOrderView(),
                transition: Transition.noTransition,
              );
            },
          ),
          AdminDrawerMenuItem(
            label: '반품 관리',
            icon: Icons.assignment_return,
            menuType: AdminMenuType.returnManagement,
            onTap: () {
              // 현재 페이지이므로 아무 동작 없음
            },
          ),
        ],
        onProfileEditTap: () async {
          // 개인정보 수정 페이지로 이동하고 결과를 받아서 드로워 갱신
          final result = await Get.to(() => const AdminProfileEditScreen());
          // 개인정보 수정이 완료되면 드로워를 갱신하기 위해 setState 호출
          if (result == true) {
            print('[DEBUG] 관리자 개인정보 수정 완료 - drawer 갱신');
            setState(() {
              // AdminStorage에서 최신 정보를 다시 읽어서 드로워가 갱신되도록 함
              // AdminDrawer는 userName과 userRole을 파라미터로 받으므로,
              // setState로 build 메서드가 다시 실행되면 AdminStorage에서 최신 정보를 읽어옴
            });
          }
        },
      ),
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
                        '반품 주문 목록',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),

                      // 반품 주문 목록 리스트 표시
                      // 반품 주문이 없으면 안내 메시지 표시, 있으면 반품 주문 카드 리스트 표시
                      if (_filteredOrders.isEmpty)
                        Center(
                          child: CustomText(
                            '반품 주문이 없습니다.',
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        // 각 반품 주문을 ReturnOrderCard로 표시
                        ..._filteredOrders.map((order) { //...는 리스트의 요소를 개별 항목으로 펼쳐 다른 리스트에 포함합니다.

                          return ReturnOrderCard(
                            orderId: order['orderId'],
                            customerName: order['customerName'],
                            orderStatus: order['orderStatus'],
                            // 현재 선택된 반품 주문인지 확인하여 선택 상태 전달
                            isSelected:
                                _selectedOrderId == order['orderId'],
                            onTap: () {
                              // 카드 클릭 시 해당 반품 주문을 선택 상태로 변경
                              setState(() {
                                _selectedOrderId = order['orderId'];
                              });
                            },
                          );
                        }),
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
                      : ReturnOrderDetailView(orderId: _selectedOrderId!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----Function Start----
  // (태블릿 관련 함수는 admin_tablet_utils.dart로 이동)

  //----Function End----
}
