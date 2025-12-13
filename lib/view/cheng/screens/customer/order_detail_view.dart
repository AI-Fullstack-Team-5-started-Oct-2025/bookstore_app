// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../Restitutor_custom/dao_custom.dart';
import '../../../../config.dart' as config;
import '../../../../model/customer.dart';
import '../../../../model/product/product.dart';
import '../../../../model/product/product_base.dart';
import '../../../../model/sale/purchase.dart';
import '../../../../model/sale/purchase_item.dart';

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Storage
import '../../storage/user_storage.dart';

// Local imports - Sub directories
import '../../widgets/customer/customer_info_card.dart';
import '../../utils/order_utils.dart';
import '../../utils/order_status_colors.dart';

/// 주문 상품 정보를 담는 클래스
class OrderItemInfo {
  final String productName;
  final int size;
  final String color;
  final int quantity;
  final int price;

  OrderItemInfo({
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
  });
}

/// 고객용 주문 상세 화면
/// 모바일 세로 화면에 최적화된 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록, 총 가격, 픽업 완료 버튼을 포함합니다.
class OrderDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const OrderDetailView({
    super.key,
    required this.purchaseId,
  });

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  /// 로딩 상태
  bool _isLoading = true;

  /// 주문 정보
  Purchase? _purchase;

  /// 고객 정보
  Customer? _customer;

  /// 주문 상품 목록
  List<OrderItemInfo> _orderItems = [];

  /// 주문 상태
  String _orderStatus = '';

  /// 픽업 완료 여부
  bool _isPickupCompleted = false;

  /// DAO 인스턴스들
  late final RDAO<Purchase> _purchaseDao;
  late final RDAO<PurchaseItem> _purchaseItemDao;
  late final RDAO<Customer> _customerDao;
  late final RDAO<Product> _productDao;
  late final RDAO<ProductBase> _productBaseDao;

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
    _productDao = RDAO<Product>(
      dbName: dbName,
      tableName: 'Product',
      dVersion: dVersion,
      fromMap: (map) => Product.fromMap(map),
    );
    _productBaseDao = RDAO<ProductBase>(
      dbName: dbName,
      tableName: 'ProductBase',
      dVersion: dVersion,
      fromMap: (map) => ProductBase.fromMap(map),
    );
    _loadOrderDetail();
  }

  /// DB에서 주문 상세 정보를 불러오는 함수
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = UserStorage.getUserId();
      if (userId == null) {
        AppLogger.w('사용자 정보가 없습니다.');
        Get.back();
        return;
      }

      AppLogger.d('=== 주문 상세 조회 시작 ===');
      AppLogger.d('주문 ID (Purchase id): ${widget.purchaseId}');

      // 주문 정보 조회 (Purchase id로)
      final purchases = await _purchaseDao.queryK({'id': widget.purchaseId});
      if (purchases.isEmpty) {
        AppLogger.w('주문을 찾을 수 없습니다: ${widget.purchaseId}');
        Get.snackbar('오류', '주문을 찾을 수 없습니다.');
        Get.back();
        return;
      }

      final purchase = purchases.first;

      // 현재 사용자(Customer id)의 주문인지 확인
      if (purchase.cid != userId) {
        AppLogger.w('권한이 없습니다. 주문 소유자(cid): ${purchase.cid}, 현재 사용자(cid): $userId');
        Get.snackbar('오류', '권한이 없습니다.');
        Get.back();
        return;
      }
      
      AppLogger.d('주문 조회 성공: id=${purchase.id}, cid=${purchase.cid}, orderCode=${purchase.orderCode}');

      // 고객 정보 조회
      if (purchase.cid != null) {
        try {
          final customers = await _customerDao.queryK({'id': purchase.cid});
          if (customers.isNotEmpty) {
            _customer = customers.first;
          }
        } catch (e) {
          AppLogger.e('고객 정보 조회 실패', error: e);
        }
      }

      // 주문 상품 목록 조회
      if (purchase.id != null) {
        final purchaseItems = await _purchaseItemDao.queryK({'pcid': purchase.id});
        AppLogger.d('=== PurchaseItem 조회 결과 ===');
        AppLogger.d('조회된 PurchaseItem 개수: ${purchaseItems.length}');
        
        // PurchaseItem ID 중복 확인
        final itemIdSet = <int>{};
        final duplicateIds = <int>[];
        for (final item in purchaseItems) {
          if (item.id != null) {
            if (itemIdSet.contains(item.id)) {
              duplicateIds.add(item.id!);
              AppLogger.w('중복된 PurchaseItem ID 발견: ${item.id}');
            } else {
              itemIdSet.add(item.id!);
            }
          }
        }
        
        if (duplicateIds.isNotEmpty) {
          AppLogger.w('중복된 PurchaseItem ID 목록: $duplicateIds');
        }

        // 상품 정보 조회 및 조합
        // 같은 제품(pid, size, color)은 수량을 합쳐서 하나의 카드로 표시
        final orderItemsMap = <String, OrderItemInfo>{}; // key: "pid_size_color"
        final processedItemIds = <int>{}; // 중복 확인용 (PurchaseItem ID 기준)
        
        for (var i = 0; i < purchaseItems.length; i++) {
          final item = purchaseItems[i];
          
          // 중복 확인 (같은 PurchaseItem ID가 이미 처리되었는지)
          if (item.id != null && processedItemIds.contains(item.id)) {
            AppLogger.w('중복된 PurchaseItem 발견: ID=${item.id}, 건너뜀');
            continue;
          }
          
          if (item.id != null) {
            processedItemIds.add(item.id!);
          }
          
          AppLogger.d('PurchaseItem[$i] 처리: id=${item.id}, pid=${item.pid}, pcid=${item.pcid}, quantity=${item.pcQuantity}, status=${item.pcStatus}');
          
          try {
            // Product 조회
            final products = await _productDao.queryK({'id': item.pid});
            if (products.isEmpty) {
              AppLogger.w('Product를 찾을 수 없음: pid=${item.pid}');
              continue;
            }
            final product = products.first;

            // ProductBase 조회
            if (product.pbid != null) {
              final productBases = await _productBaseDao.queryK({'id': product.pbid});
              if (productBases.isEmpty) {
                AppLogger.w('ProductBase를 찾을 수 없음: pbid=${product.pbid}');
                continue;
              }
              final productBase = productBases.first;

              // 같은 제품(pid, size, color)을 구분하는 키 생성
              final itemKey = '${item.pid}_${product.size}_${productBase.pColor}';
              
              if (orderItemsMap.containsKey(itemKey)) {
                // 이미 같은 제품이 있으면 수량만 합산
                final existingItem = orderItemsMap[itemKey]!;
                final updatedItem = OrderItemInfo(
                  productName: existingItem.productName,
                  size: existingItem.size,
                  color: existingItem.color,
                  quantity: existingItem.quantity + item.pcQuantity, // 수량 합산
                  price: existingItem.price,
                );
                orderItemsMap[itemKey] = updatedItem;
                AppLogger.d('기존 OrderItem 수량 합산: ${existingItem.productName}, 기존 수량=${existingItem.quantity}, 추가 수량=${item.pcQuantity}, 총 수량=${updatedItem.quantity}');
              } else {
                // 새로운 제품이면 추가
                final orderItem = OrderItemInfo(
                  productName: productBase.pName,
                  size: product.size,
                  color: productBase.pColor,
                  quantity: item.pcQuantity,
                  price: product.basePrice,
                );
                orderItemsMap[itemKey] = orderItem;
                AppLogger.d('OrderItem 추가: ${orderItem.productName}, 사이즈=${orderItem.size}, 색상=${orderItem.color}, 수량=${orderItem.quantity}, 가격=${orderItem.price}');
              }
            }
          } catch (e) {
            AppLogger.e('상품 정보 조회 실패 (pid: ${item.pid})', error: e);
          }
        }
        
        // Map을 List로 변환
        final orderItemsList = orderItemsMap.values.toList();
        
        AppLogger.d('=== 최종 결과 ===');
        AppLogger.d('PurchaseItem 개수: ${purchaseItems.length}');
        AppLogger.d('OrderItem 개수: ${orderItemsList.length}');
        AppLogger.d('처리된 PurchaseItem ID: $processedItemIds');

        // 주문 상태 확인 (리스트 페이지에서 이미 30일 경과 처리를 했으므로 DB 상태만 읽음)
        // 픽업 완료 여부 결정 (모든 아이템이 완료 상태인지 확인)
        final allCompleted = purchaseItems.every((item) {
          final statusNum = _parseStatusToNumber(item.pcStatus);
          return statusNum == 2; // 제품 수령 완료
        });
        
        // 주문 상태 결정 (DB에 저장된 PurchaseItem 상태 기반)
        final orderStatus = _determineOrderStatus(purchaseItems, purchase);
        
        AppLogger.d('주문 상태: $orderStatus, 픽업 완료 여부: $allCompleted');

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _isPickupCompleted = allCompleted;
          _orderStatus = orderStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('주문 상세 로드 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '주문 정보를 불러올 수 없습니다.');
      setState(() {
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

  /// 픽업 완료 처리 함수
  Future<void> _handlePickupComplete() async {
    if (_purchase?.id == null) {
      return;
    }

    try {
      // 모든 PurchaseItem의 상태를 '제품 수령 완료'로 업데이트
      final purchaseItems = await _purchaseItemDao.queryK({'pcid': _purchase!.id});
      final completeStatus = config.pickupStatus[2] ?? '제품 수령 완료';
      
      for (final item in purchaseItems) {
        if (item.id != null) {
          await _purchaseItemDao.updateK(
            {'pcStatus': completeStatus}, // pickupStatus[2]의 실제 값(문자열) 사용
            {'id': item.id},
          );
          AppLogger.d('PurchaseItem ID ${item.id} 업데이트 완료: pcStatus = $completeStatus');
        }
      }

      // 상태 업데이트
      setState(() {
        _isPickupCompleted = true;
        _orderStatus = completeStatus;
      });

      Get.snackbar(
        '픽업 완료',
        '픽업이 완료되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 이전 페이지로 돌아가기 (result를 true로 전달하여 리스트 페이지에서 갱신하도록 함)
      Get.back(result: true);
    } catch (e, stackTrace) {
      AppLogger.e('픽업 완료 처리 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '픽업 완료 처리에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        appBar: CustomAppBar(
          title: '주문 상세',
          centerTitle: true,
          titleTextStyle: config.rLabel,
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_purchase == null || _customer == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        appBar: CustomAppBar(
          title: '주문 상세',
          centerTitle: true,
          titleTextStyle: config.rLabel,
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('주문 정보를 불러올 수 없습니다.'),
        ),
      );
    }

    // 주문 상품들의 총 가격 계산
    final totalPrice = _orderItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: CustomAppBar(
        title: '주문 상세',
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
                // 주문 ID 표시
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        '주문번호: ${_purchase?.orderCode ?? widget.purchaseId.toString()}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      // 주문 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrderStatusColors.getStatusColor(_orderStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          _orderStatus,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // 주문자 상세 정보 카드
                CustomerInfoCard(
                  name: _customer!.cName,
                  phone: _customer!.cPhoneNumber,
                  email: _customer!.cEmail,
                ),

                // 주문 상품들 제목
                CustomText(
                  '주문 상품',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 주문 상품 리스트 (각 상품을 카드로 표시)
                if (_orderItems.isEmpty)
                  CustomText(
                    '주문 상품이 없습니다.',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  )
                else
                  ..._orderItems.map((item) {
                    return CustomCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      child: CustomColumn(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          // 상품명
                          CustomText(
                            item.productName,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          // 상품 정보 (사이즈, 색상, 수량)
                          CustomRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                '사이즈: ${item.size} | 색상: ${item.color} | 수량: ${item.quantity}',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey.shade600,
                              ),
                              // 가격 표시 (오른쪽 정렬)
                              CustomText(
                                '${formatPrice(item.price * item.quantity)}원',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                // 총 가격 표시 카드
                CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        '총 주문 금액',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        '${formatPrice(totalPrice)}원',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),

                // 픽업 완료 버튼
                // 제품 준비 완료 상태이고 아직 픽업 완료되지 않은 경우에만 활성화
                if (!_isPickupCompleted && _orderStatus == (config.pickupStatus[1] ?? '제품 준비 완료'))
                  CustomButton(
                    btnText: '픽업 완료',
                    buttonType: ButtonType.elevated,
                    onCallBack: _handlePickupComplete,
                    minimumSize: const Size(double.infinity, 50),
                  )
                else
                  // 픽업 완료된 경우 또는 제품 수령 완료 상태인 경우 비활성화된 버튼 표시 (회색 처리)
                  IgnorePointer(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: CustomText(
                          '픽업 완료',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

