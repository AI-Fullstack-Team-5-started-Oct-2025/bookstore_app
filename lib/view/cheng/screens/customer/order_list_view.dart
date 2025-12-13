// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../Restitutor_custom/dao_custom.dart';
import '../../../../config.dart' as config;
import '../../../../model/customer.dart';
import '../../../../model/sale/purchase.dart';
import '../../../../model/sale/purchase_item.dart';

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Storage
import '../../storage/user_storage.dart';

// Local imports - Sub directories
import '../../widgets/customer/customer_order_card.dart';

// Local imports - Screens
import 'order_detail_view.dart';

/// 고객용 주문 내역 화면
/// 모바일 세로 화면에 최적화된 주문 내역 화면입니다.
/// 검색 필터와 주문 카드 리스트를 표시하며, 카드를 탭하면 상세 페이지로 이동합니다.
class OrderListView extends StatefulWidget {
  const OrderListView({super.key});

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  /// 검색 필터 입력을 위한 텍스트 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 주문 내역 데이터
  List<Purchase> _orders = [];

  /// 주문 상태 맵 (주문 ID -> 상태)
  Map<int, String> _orderStatusMap = {};

  /// 로딩 상태
  bool _isLoading = true;

  /// 정렬 기준 (기본값: 주문 번호)
  String _sortBy = 'orderCode';

  /// 정렬 방향 (true: 오름차순, false: 내림차순)
  bool _sortAscending = true;

  /// 현재 로그인한 사용자 정보
  Customer? _currentUser;

  // 임시 주문 내역 데이터 (참고용 - 주석 처리)
  // final List<Map<String, dynamic>> _tempOrders = [
  //   {
  //     'orderId': 'ORD001',
  //     'orderStatus': '대기중',
  //     'orderDate': '2024-12-01',
  //     'totalPrice': 120000,
  //   },
  //   {
  //     'orderId': 'ORD002',
  //     'orderStatus': '준비완료',
  //     'orderDate': '2024-12-02',
  //     'totalPrice': 150000,
  //   },
  //   {
  //     'orderId': 'ORD003',
  //     'orderStatus': '픽업완료',
  //     'orderDate': '2024-12-03',
  //     'totalPrice': 200000,
  //   },
  // ];

  /// Purchase DAO 인스턴스
  late final RDAO<Purchase> _purchaseDao;

  /// PurchaseItem DAO 인스턴스
  late final RDAO<PurchaseItem> _purchaseItemDao;

  /// Customer DAO 인스턴스
  late final RDAO<Customer> _customerDao;

  @override
  void initState() {
    super.initState();
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
    _customerDao = RDAO<Customer>(
      dbName: dbName,
      tableName: 'Customer',
      dVersion: dVersion,
      fromMap: (map) => Customer.fromMap(map),
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// DB에서 주문 목록을 불러오는 함수
  /// 현재 로그인한 사용자의 주문만 필터링하여 가져옵니다.
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserStorage.getUserId();
      if (userId == null) {
        AppLogger.w('사용자 정보가 없습니다. 로그인이 필요합니다.');
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      // 현재 사용자의 주문 내역 조회
      AppLogger.d('=== 주문 내역 조회 시작 ===');
      AppLogger.d('사용자 ID: $userId');
      
      // 현재 사용자 정보 가져오기 (디버깅용)
      try {
        final customers = await _customerDao.queryK({'id': userId});
        if (customers.isNotEmpty) {
          _currentUser = customers.first;
          AppLogger.d('사용자 정보 로드 성공: 이름=${_currentUser!.cName}, 이메일=${_currentUser!.cEmail}');
        } else {
          AppLogger.w('사용자 정보를 찾을 수 없습니다. ID: $userId');
        }
      } catch (e) {
        AppLogger.e('사용자 정보 조회 실패', error: e);
      }
      
      final purchases = await _purchaseDao.queryK({'cid': userId});
      
      AppLogger.d('조회된 Purchase 개수: ${purchases.length}');
      for (var i = 0; i < purchases.length; i++) {
        final purchase = purchases[i];
        AppLogger.d('--- Purchase[$i] ---');
        AppLogger.d('  id: ${purchase.id}');
        AppLogger.d('  cid: ${purchase.cid}');
        AppLogger.d('  orderCode: ${purchase.orderCode}');
        AppLogger.d('  pickupDate: ${purchase.pickupDate}');
        AppLogger.d('  timeStamp: ${purchase.timeStamp}');
      }
      
      // 시간순으로 정렬 (최신순)
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // 모든 PurchaseItem 조회 및 콘솔 출력
      AppLogger.d('\n${'=' * 80}');
      AppLogger.d('=== PurchaseItem 전체 리스트 ===');
      AppLogger.d('=' * 80);
      
      try {
        final allPurchaseItems = await _purchaseItemDao.queryAll();
        AppLogger.d('전체 PurchaseItem 개수: ${allPurchaseItems.length}');
        AppLogger.d('-' * 80);
        
        for (var i = 0; i < allPurchaseItems.length; i++) {
          final item = allPurchaseItems[i];
          AppLogger.d('PurchaseItem[$i]:');
          AppLogger.d('  id: ${item.id}');
          AppLogger.d('  pid (Product id): ${item.pid}');
          AppLogger.d('  pcid (Purchase id): ${item.pcid}');
          AppLogger.d('  pcQuantity (수량): ${item.pcQuantity}');
          AppLogger.d('  pcStatus (상태): "${item.pcStatus}"');
          AppLogger.d('-' * 80);
        }
        
        AppLogger.d('=== PurchaseItem 전체 리스트 출력 완료 ===');
        AppLogger.d('${'=' * 80}\n');
      } catch (e) {
        AppLogger.e('PurchaseItem 전체 조회 실패', error: e);
      }

      // 각 주문의 상태를 미리 계산 및 30일 경과 주문 자동 업데이트
      final statusMap = <int, String>{};
      final now = DateTime.now();
      
      for (final purchase in purchases) {
        if (purchase.id != null) {
          try {
            AppLogger.d('--- PurchaseItem 조회 (pcid: ${purchase.id}) ---');
            final items = await _purchaseItemDao.queryK({'pcid': purchase.id});
            AppLogger.d('조회된 PurchaseItem 개수: ${items.length}');
            for (var j = 0; j < items.length; j++) {
              final item = items[j];
              AppLogger.d('  PurchaseItem[$j]: id=${item.id}, pid=${item.pid}, pcid=${item.pcid}, pcQuantity=${item.pcQuantity}, pcStatus="${item.pcStatus}"');
            }
            
            // 30일 경과 확인 및 자동 업데이트
            // 반품 상태(3 이상)가 아닌 경우에만 자동 업데이트 수행
            final pickupDate = DateTime.tryParse(purchase.pickupDate);
            bool shouldUpdateToComplete = false;
            
            // 반품 상태(3 이상)가 있는지 확인
            final hasReturnStatus = items.any((item) {
              final statusNum = _parseStatusToNumber(item.pcStatus);
              return statusNum >= 3;
            });
            
            if (pickupDate != null && !hasReturnStatus) {
              final daysDifference = now.difference(pickupDate).inDays;
              if (daysDifference >= 30) {
                AppLogger.d('주문 ID ${purchase.id}: 30일 경과 ($daysDifference일) - 자동 수령 완료 처리');
                shouldUpdateToComplete = true;
                
                // 모든 PurchaseItem의 pcStatus를 '제품 수령 완료'로 업데이트
                final completeStatus = config.pickupStatus[2] ?? '제품 수령 완료';
                for (final item in items) {
                  if (item.id != null) {
                    try {
                      await _purchaseItemDao.updateK(
                        {'pcStatus': completeStatus}, // pickupStatus[2] = '제품 수령 완료'
                        {'id': item.id},
                      );
                      AppLogger.d('PurchaseItem ID ${item.id} 업데이트 완료: pcStatus = $completeStatus');
                    } catch (e) {
                      AppLogger.e('PurchaseItem 업데이트 실패 (ID: ${item.id})', error: e);
                    }
                  }
                }
              }
            }
            
            // 상태 결정 (30일 경과면 자동으로 수령 완료)
            final status = shouldUpdateToComplete 
                ? (config.pickupStatus[2] ?? '제품 수령 완료')
                : _determineOrderStatus(items, purchase);
            AppLogger.d('결정된 주문 상태: $status');
            statusMap[purchase.id!] = status;
          } catch (e) {
            AppLogger.e('주문 상태 조회 실패 (ID: ${purchase.id})', error: e);
            statusMap[purchase.id!] = config.pickupStatus[0] ?? '제품 준비 중';
          }
        }
      }
      
      AppLogger.d('=== 주문 내역 조회 완료 ===');

      setState(() {
        _orders = purchases;
        _orderStatusMap = statusMap;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('주문 내역 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

  /// PurchaseItem 목록을 기반으로 주문 전체 상태를 결정하는 함수
  /// config.dart의 pickupStatus를 사용하여 상태를 결정합니다.
  /// 주문 내역 화면이므로 픽업 완료 이상의 상태(2, 3, 4, 5)는 모두 "제품 수령 완료"로 표시합니다.
  String _determineOrderStatus(List<PurchaseItem> items, Purchase purchase) {
    if (items.isEmpty) {
      return config.pickupStatus[0] ?? '제품 준비 중';
    }

    // 모든 아이템의 상태를 숫자로 변환
    final statusNumbers = items.map((item) => _parseStatusToNumber(item.pcStatus)).toList();
    
    // 반품 상태(3 이상)가 있는지 확인
    final hasReturnStatus = statusNumbers.any((status) => status >= 3);
    
    // 30일 경과 확인 (반품 상태가 아닌 경우에만 적용)
    if (!hasReturnStatus) {
      final pickupDate = DateTime.tryParse(purchase.pickupDate);
      if (pickupDate != null) {
        final daysDifference = DateTime.now().difference(pickupDate).inDays;
        if (daysDifference >= 30) {
          return config.pickupStatus[2] ?? '제품 수령 완료';
        }
      }
    }

    // 모든 아이템이 같은 상태인지 확인
    final firstStatus = statusNumbers.first;
    final allSameStatus = statusNumbers.every((status) => status == firstStatus);
    
    // 상태 결정: 0, 1은 그대로, 2 이상은 모두 "제품 수령 완료"로 표시
    int displayStatus;
    if (allSameStatus) {
      displayStatus = firstStatus;
    } else {
      // 상태가 다르면 가장 낮은 상태를 반환 (보수적 접근)
      displayStatus = statusNumbers.reduce((a, b) => a < b ? a : b);
    }
    
    // 픽업 완료 이상의 상태(2, 3, 4, 5)는 모두 "제품 수령 완료"로 표시
    if (displayStatus >= 2) {
      return config.pickupStatus[2] ?? '제품 수령 완료';
    }
    
    // 0, 1 상태는 그대로 반환
    if (displayStatus >= 0 && displayStatus <= 1) {
      return config.pickupStatus[displayStatus] ?? '제품 준비 중';
    }
    
    // 기본값: 제품 준비 중
    return config.pickupStatus[0] ?? '제품 준비 중';
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

  /// 검색어에 따라 필터링되고 정렬된 주문 목록을 반환하는 getter
  /// 검색어가 비어있으면 전체 목록을 반환하고,
  /// 검색어가 있으면 주문 번호 또는 주문 날짜로 필터링합니다.
  /// 정렬은 주문 번호 또는 주문일 기준으로 가능합니다.
  List<Purchase> get _filteredOrders {
    var filtered = _orders;
    
    // 검색 필터링 (주문 번호 또는 주문 날짜)
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((order) {
        // 주문 번호로 검색
        if (order.orderCode.toLowerCase().contains(searchText)) {
          return true;
        }
        
        // 주문 날짜로 검색 (여러 형식 지원)
        final orderDate = _normalizeDate(order.timeStamp);
        final searchDate = _normalizeDate(searchText);
        
        // 정규화된 날짜로 비교
        if (orderDate.contains(searchDate) || searchDate.contains(orderDate)) {
          return true;
        }
        
        // 원본 날짜 문자열도 확인 (timeStamp, pickupDate)
        if (order.timeStamp.toLowerCase().contains(searchText) ||
            order.pickupDate.toLowerCase().contains(searchText)) {
          return true;
        }
        
        return false;
      }).toList();
    }
    
    // 정렬 (주문 번호 또는 주문일 기준)
    filtered.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'orderCode':
          comparison = a.orderCode.compareTo(b.orderCode);
          break;
        case 'orderDate':
          // timeStamp를 기준으로 정렬
          comparison = a.timeStamp.compareTo(b.timeStamp);
          break;
        default:
          comparison = a.orderCode.compareTo(b.orderCode);
      }
      
      return _sortAscending ? comparison : -comparison;
    });
    
    return filtered;
  }

  /// 정렬 기준 변경
  void _changeSortOrder(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        // 같은 기준이면 정렬 방향만 변경
        _sortAscending = !_sortAscending;
      } else {
        // 다른 기준이면 새 기준으로 오름차순 정렬
        _sortBy = sortBy;
        _sortAscending = true;
      }
    });
  }

  /// 날짜 문자열을 정규화하는 함수
  /// 여러 형식(20251222, 2025-12-22, 2025/12/22)을 숫자만 있는 형식으로 변환
  /// 예: "2025-12-22" -> "20251222", "2025/12/22" -> "20251222"
  String _normalizeDate(String dateString) {
    // 숫자와 하이픈, 슬래시만 추출
    final cleaned = dateString.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned;
  }

  /// 주문 카드 위젯을 생성하는 메서드
  Widget _buildOrderCard(Purchase order) {
    // 주문 상태 가져오기 (미리 계산된 상태 사용)
    // _loadOrders에서 이미 30일 경과 처리 및 상태 결정이 완료되었으므로 그대로 사용
    String orderStatus = order.id != null 
        ? _orderStatusMap[order.id] ?? config.pickupStatus[0] ?? '제품 준비 중'
        : config.pickupStatus[0] ?? '제품 준비 중';
    
    // 날짜 포맷팅 (timeStamp에서 날짜만 추출)
    final orderDate = order.timeStamp.split(' ').first;
    
    return GestureDetector(
      onTap: () async {
        // 카드 클릭 시 주문 상세 페이지로 이동 (주문 ID 전달)
        if (order.id != null) {
          await Get.to(
            () => OrderDetailView(purchaseId: order.id!),
          );
          // 상세 페이지에서 돌아올 때마다 목록 갱신 (상태 변경 가능성 있음)
          _loadOrders();
        }
      },
      child: CustomerOrderCard(
        orderId: order.orderCode,
        orderStatus: orderStatus,
        orderDate: orderDate,
        totalPrice: null, // TODO: PurchaseItem과 Product를 조인하여 총액 계산
      ),
    );
  }

  /// 로딩 인디케이터 위젯
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 빈 주문 내역 메시지 위젯
  Widget _buildEmptyMessage() {
    return Center(
      child: CustomPadding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: CustomText(
          '주문 내역이 없습니다.',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 주문 내역 위젯
  Widget _buildOrderList() {
    return Column(
      children: _filteredOrders.map((order) => _buildOrderCard(order)).toList(),
    );
  }

  /// 정렬 버튼 위젯
  Widget _buildSortButton(String sortBy, String label) {
    final isActive = _sortBy == sortBy;
    final icon = isActive
        ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.sort;
    
    return GestureDetector(
      onTap: () => _changeSortOrder(sortBy),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: CustomRow(
          spacing: 4,
          children: [
            CustomText(
              label,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            Icon(icon, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: CustomAppBar(
        title: '주문 내역',
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
                  hintText: '주문번호 또는 주문날짜로 검색',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (_) => setState(() {}),
                ),

                // 정렬 옵션 (주문 번호, 주문일)
                CustomRow(
                  mainAxisAlignment: MainAxisAlignment.start,
                  spacing: 8,
                  children: [
                    _buildSortButton('orderCode', '주문번호'),
                    _buildSortButton('orderDate', '주문일'),
                  ],
                ),

                // 주문 내역 제목
                CustomText(
                  '주문 내역 (수령 예상일로 부터 30일이 지난 주문은 자동으로 수령 완료 처리 됩니다.)',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 주문 내역 리스트 표시
                if (_isLoading)
                  _buildLoadingIndicator()
                else if (_filteredOrders.isEmpty)
                  _buildEmptyMessage()
                else
                  _buildOrderList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

