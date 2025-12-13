// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../Restitutor_custom/dao_custom.dart';
import '../../../../config.dart' as config;
import '../../../../model/sale/purchase.dart';
import '../../../../model/sale/purchase_item.dart';

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Storage
import '../../storage/user_storage.dart';

// Local imports - Sub directories
import '../../widgets/customer/customer_order_card.dart';

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

  /// 주문 목록 데이터 (상태 2 이상)
  List<Purchase> _orders = [];

  /// 주문 상태 맵 (주문 ID -> 상태)
  Map<int, String> _orderStatusMap = {};

  /// 로딩 상태
  bool _isLoading = true;

  /// 정렬 기준 (기본값: 주문 번호)
  String _sortBy = 'orderCode';

  /// 정렬 방향 (true: 오름차순, false: 내림차순)
  bool _sortAscending = true;

  /// Purchase DAO 인스턴스
  late final RDAO<Purchase> _purchaseDao;

  /// PurchaseItem DAO 인스턴스
  late final RDAO<PurchaseItem> _purchaseItemDao;

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
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// DB에서 수령 완료 이상 상태(2 이상)의 주문 목록을 불러오는 함수
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

      AppLogger.d('=== 수령 완료 목록 조회 시작 ===');
      AppLogger.d('사용자 ID: $userId');

      // 현재 사용자의 주문 목록 조회
      final purchases = await _purchaseDao.queryK({'cid': userId});
      AppLogger.d('조회된 Purchase 개수: ${purchases.length}');

      // 시간순으로 정렬 (최신순)
      purchases.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

      // 상태가 2 이상인 주문만 필터링하고 반품 가능 여부 확인
      final completedOrders = <Purchase>[];
      final statusMap = <int, String>{};
      final now = DateTime.now();
      
      for (final purchase in purchases) {
        if (purchase.id != null) {
          try {
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
              
              AppLogger.d('수령 완료 주문 추가: id=${purchase.id}, orderCode=${purchase.orderCode}, 반품 상태: $returnStatus');
            }
          } catch (e) {
            AppLogger.e('주문 상태 조회 실패 (ID: ${purchase.id})', error: e);
          }
        }
      }

      AppLogger.d('=== 수령 완료 목록 조회 완료 (${completedOrders.length}개) ===');

      setState(() {
        _orders = completedOrders;
        _orderStatusMap = statusMap;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      AppLogger.e('수령 완료 목록 로드 실패', error: e, stackTrace: stackTrace);
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

  /// 검색어에 따라 필터링되고 정렬된 주문 목록을 반환하는 getter
  /// order_list_view.dart와 동일한 로직
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
  String _normalizeDate(String dateString) {
    // 숫자와 하이픈, 슬래시만 추출
    final cleaned = dateString.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned;
  }

  /// 주문 카드 위젯을 생성하는 메서드
  Widget _buildOrderCard(Purchase order) {
    // 날짜 포맷팅 (timeStamp에서 날짜만 추출)
    final orderDate = order.timeStamp.split(' ').first;
    
    // 주문 상태 가져오기 (미리 계산된 상태 사용)
    String orderStatus = order.id != null 
        ? _orderStatusMap[order.id] ?? '반품 불가'
        : '반품 불가';

    return GestureDetector(
      onTap: () async {
        // 카드 클릭 시 반품 상세 페이지로 이동 (주문 ID 전달)
        if (order.id != null) {
          await Get.to(
            () => ReturnDetailView(purchaseId: order.id!),
          );
          // 상세 페이지에서 돌아올 때마다 목록 갱신
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

  /// 빈 주문 목록 메시지 위젯
  Widget _buildEmptyMessage() {
    return Center(
      child: CustomPadding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: CustomText(
          '수령 완료 내역이 없습니다.',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 주문 목록 위젯
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
        title: '수령완료 / 반품 목록',
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

                // 수령완료 / 반품 목록 제목
                CustomText(
                  '수령완료 / 반품 목록',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 수령 완료 목록 리스트 표시
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


