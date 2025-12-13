// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../Restitutor_custom/dao_custom.dart';
import '../../../../config.dart' as config;
import '../../../../model/customer.dart';
import '../../../../model/employee.dart';
import '../../../../model/sale/purchase.dart';
import '../../../../model/sale/purchase_item.dart';

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Sub directories
import '../../widgets/admin/admin_drawer.dart';
import '../../storage/admin_storage.dart';
import '../../utils/admin_tablet_utils.dart';
import '../../widgets/admin/return_order_card.dart';
import '../../widgets/admin/return_order_detail_view.dart';

// Local imports - Screens
import 'admin_order_view.dart';
import 'admin_profile_edit_view.dart';

/// 관리자/직원 반품 관리 화면
/// 태블릿에서 가로 모드로 강제 표시되는 반품 관리 화면입니다.
/// 좌측에 반품 주문 목록을 표시하고, 우측에 선택된 반품 주문의 상세 정보를 표시합니다.

class AdminReturnOrderView extends StatefulWidget {
  const AdminReturnOrderView({super.key});

  @override
  State<AdminReturnOrderView> createState() =>
      _AdminReturnOrderViewState();
}

class _AdminReturnOrderViewState
    extends State<AdminReturnOrderView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 현재 선택된 반품 주문 ID (Purchase id)
  /// null이면 우측에 "데이터 없음" 메시지 표시
  int? _selectedOrderId;

  /// 주문 목록 데이터 (상태 2 이상)
  List<Purchase> _orders = [];

  /// 주문 상태 맵 (주문 ID -> 상태)
  Map<int, String> _orderStatusMap = {};

  /// 고객 정보 맵 (주문 ID -> 고객명)
  Map<int, String> _customerNameMap = {};

  /// 로딩 상태
  bool _isLoading = true;

  /// 직원 데이터 접근 객체 (initState에서 초기화)
  late final RDAO<Employee> employeeDAO;
  /// 고객 데이터 접근 객체 (initState에서 초기화)
  late final RDAO<Customer> customerDAO;
  /// Purchase DAO 인스턴스
  late final RDAO<Purchase> _purchaseDao;
  /// PurchaseItem DAO 인스턴스
  late final RDAO<PurchaseItem> _purchaseItemDao;

  /// 검색어에 따라 필터링된 반품 주문 목록을 반환하는 getter
  /// 검색어가 비어있으면 전체 목록을 반환하고,
  /// 검색어가 있으면 주문 번호 또는 고객명에 검색어가 포함된 반품 주문만 필터링하여 반환합니다.
  List<Purchase> get _filteredOrders {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _orders;
    }
    return _orders.where((order) {
      // 주문 번호로 검색
      if (order.orderCode.toLowerCase().contains(searchText)) {
        return true;
      }
      // 고객명으로 검색
      final customerName = _customerNameMap[order.id] ?? '';
      if (customerName.toLowerCase().contains(searchText)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    
    employeeDAO = RDAO<Employee>(
      dbName: dbName,
      tableName: config.tTableEmployee,
      dVersion: dVersion,
      fromMap: Employee.fromMap,
    );
    customerDAO = RDAO<Customer>(
      dbName: dbName,
      tableName: config.kTableCustomer,
      dVersion: dVersion,
      fromMap: Customer.fromMap,
    );
    _purchaseDao = RDAO<Purchase>(
      dbName: dbName,
      tableName: 'Purchase',
      dVersion: dVersion,
      fromMap: (map) => Purchase.fromMap(map),
    );
    _purchaseItemDao = RDAO<PurchaseItem>(
      dbName: dbName,
      tableName: 'PurchaseItem',
      dVersion: dVersion,
      fromMap: (map) => PurchaseItem.fromMap(map),
    );
    
    // 페이지 진입 시 태블릿이면 가로 모드로 고정
    lockTabletLandscape(context);
    
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // 페이지 나갈 때 모든 방향 허용으로 복구
    unlockAllOrientations();
    super.dispose();
  }

  /// DB에서 수령 완료 이상 상태(2 이상)의 주문 목록을 불러오는 함수
  /// 관리자는 모든 주문을 볼 수 있습니다.
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.d('=== 관리자 반품 주문 목록 조회 시작 ===');
      
      // 모든 주문 조회 (관리자는 모든 주문을 볼 수 있음)
      final purchases = await _purchaseDao.queryAll();
      AppLogger.d('조회된 Purchase 개수: ${purchases.length}');
      
      // 시간순으로 정렬 (최신순)
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // 상태가 2 이상인 주문만 필터링하고 반품 가능 여부 확인
      final completedOrders = <Purchase>[];
      final statusMap = <int, String>{};
      final customerNameMap = <int, String>{};
      final now = DateTime.now();
      
      for (final purchase in purchases) {
        if (purchase.id != null) {
          try {
            // 고객 정보 조회
            if (purchase.cid != null) {
              final customers = await customerDAO.queryK({'id': purchase.cid});
              if (customers.isNotEmpty) {
                customerNameMap[purchase.id!] = customers.first.cName;
              }
            }
            
            // PurchaseItem 조회
            final items = await _purchaseItemDao.queryK({'pcid': purchase.id});
            
            // 모든 PurchaseItem의 상태를 확인
            bool hasStatus2OrAbove = false;
            for (final item in items) {
              final statusNum = _parseStatusToNumber(item.pcStatus);
              if (statusNum >= 2) {
                hasStatus2OrAbove = true;
                break;
              }
            }
            
            // 상태가 2 이상인 주문만 추가
            if (hasStatus2OrAbove) {
              completedOrders.add(purchase);
              
              // 반품 가능 여부 결정
              final returnStatus = _determineReturnStatus(items, purchase, now);
              statusMap[purchase.id!] = returnStatus;
              
              AppLogger.d('반품 주문 추가: id=${purchase.id}, orderCode=${purchase.orderCode}, 반품 상태: $returnStatus');
            }
          } catch (e) {
            AppLogger.e('주문 상태 조회 실패 (ID: ${purchase.id})', error: e);
          }
        }
      }
      
      AppLogger.d('=== 관리자 반품 주문 목록 조회 완료 (${completedOrders.length}개) ===');

      setState(() {
        _orders = completedOrders;
        _orderStatusMap = statusMap;
        _customerNameMap = customerNameMap;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('반품 주문 목록 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

  /// 반품 가능 여부를 결정하는 함수
  /// 하나라도 반품 가능하면 "반품 가능", 모두 반품 완료되면 "반품 불가" 반환
  String _determineReturnStatus(List<PurchaseItem> items, Purchase purchase, DateTime now) {
    if (items.isEmpty) {
      return '반품 불가';
    }

    final pickupDate = DateTime.tryParse(purchase.pickupDate);
    bool hasReturnableItem = false;
    bool allReturnCompleted = true;
    
    for (final item in items) {
      final statusNum = _parseStatusToNumber(item.pcStatus);
      
      // 반품 완료(5)가 아닌 경우 allReturnCompleted를 false로 설정
      if (statusNum != 5) {
        allReturnCompleted = false;
      }
      
      // 반품 가능 조건: 상태가 2 (제품 수령 완료)이고 30일이 지나지 않았으면 반품 가능
      if (statusNum == 2) {
        if (pickupDate != null) {
          final daysDifference = now.difference(pickupDate).inDays;
          if (daysDifference < 30) {
            // 반품 가능한 아이템이 하나라도 있으면
            hasReturnableItem = true;
          }
        }
      }
    }

    // 모든 아이템이 반품 완료(5)이면 "반품 불가"
    if (allReturnCompleted) {
      return '반품 불가';
    }
    
    // 하나라도 반품 가능한 아이템이 있으면 "반품 가능"
    if (hasReturnableItem) {
      return '반품 가능';
    }

    // 그 외의 경우 (반품 신청, 반품 처리 중, 30일 경과 등) "반품 불가"
    return '반품 불가';
  }

  /// pcStatus를 숫자로 파싱하는 함수
  /// config.pickupStatus의 키와 밸류를 비교하여 숫자로 변환
  int _parseStatusToNumber(String pcStatus) {
    // 1. 숫자 문자열인 경우 (예: '0', '1', '2', '3', '4', '5')
    final numericStatus = int.tryParse(pcStatus);
    if (numericStatus != null && numericStatus >= 0 && numericStatus <= 5) {
      return numericStatus;
    }
    
    // 2. pickupStatus의 키(숫자), 키(문자열), 밸류(문자열)와 비교
    for (var entry in config.pickupStatus.entries) {
      // 키(숫자)와 직접 비교
      if (pcStatus == entry.key.toString()) {
        return entry.key;
      }
      // 밸류(문자열)와 비교
      if (pcStatus == entry.value) {
        return entry.key;
      }
    }
    
    // 기본값: 제품 준비 중
    return 0;
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
                () => const AdminOrderView(),
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
          final result = await Get.to(() => const AdminProfileEditView());
          if (result == true) {
            AppLogger.d('관리자 개인정보 수정 완료 - drawer 갱신', tag: 'ReturnOrderView');
            setState(() {});
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
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_filteredOrders.isEmpty)
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
                        ..._filteredOrders.map((order) {
                          final orderStatus = order.id != null 
                              ? _orderStatusMap[order.id] ?? '반품 불가'
                              : '반품 불가';
                          final customerName = order.id != null
                              ? _customerNameMap[order.id] ?? '고객 정보 없음'
                              : '고객 정보 없음';
                          
                          return ReturnOrderCard(
                            orderId: order.orderCode,
                            customerName: customerName,
                            orderStatus: orderStatus,
                            // 현재 선택된 반품 주문인지 확인하여 선택 상태 전달
                            isSelected: _selectedOrderId == order.id,
                            onTap: () {
                              // 카드 클릭 시 해당 반품 주문을 선택 상태로 변경
                              setState(() {
                                _selectedOrderId = order.id;
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
                      : ReturnOrderDetailView(purchaseId: _selectedOrderId!),
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
