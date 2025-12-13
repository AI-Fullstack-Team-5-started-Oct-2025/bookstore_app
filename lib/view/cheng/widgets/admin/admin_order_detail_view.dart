// Flutter imports
import 'package:flutter/material.dart';

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

// Local imports - Widgets
import '../customer/customer_info_card.dart';

// Local imports - Utils
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

/// 관리자용 주문 상세 정보 뷰
/// 주문 관리 화면의 우측에 표시되는 주문 상세 정보를 보여주는 위젯입니다.
/// 읽기 전용으로, 버튼은 비활성화되어 있습니다.
class AdminOrderDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const AdminOrderDetailView({
    super.key,
    required this.purchaseId,
  });

  @override
  State<AdminOrderDetailView> createState() => _AdminOrderDetailViewState();
}

class _AdminOrderDetailViewState extends State<AdminOrderDetailView> {
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

  @override
  void didUpdateWidget(AdminOrderDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // purchaseId가 변경되면 데이터를 다시 로드
    if (oldWidget.purchaseId != widget.purchaseId) {
      _loadOrderDetail();
    }
  }

  /// DB에서 주문 상세 정보를 불러오는 함수
  /// 관리자는 모든 주문을 볼 수 있습니다.
  Future<void> _loadOrderDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AppLogger.d('=== 관리자 주문 상세 조회 시작 ===');
      AppLogger.d('주문 ID (Purchase id): ${widget.purchaseId}');

      // 주문 정보 조회 (Purchase id로)
      final purchases = await _purchaseDao.queryK({'id': widget.purchaseId});
      if (purchases.isEmpty) {
        AppLogger.w('주문을 찾을 수 없습니다: ${widget.purchaseId}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final purchase = purchases.first;
      AppLogger.d('주문 조회 성공: id=${purchase.id}, cid=${purchase.cid}, orderCode=${purchase.orderCode}');
      
      // Purchase 상세 정보 로그 출력
      AppLogger.d('=== Purchase 상세 정보 ===');
      AppLogger.d('Purchase ID: ${purchase.id}');
      AppLogger.d('Customer ID (cid): ${purchase.cid}');
      AppLogger.d('Order Code: ${purchase.orderCode}');
      AppLogger.d('Pickup Date: ${purchase.pickupDate}');
      AppLogger.d('Time Stamp: ${purchase.timeStamp}');
      AppLogger.d('=' * 50);

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
        AppLogger.d('=' * 50);
        
        // 각 PurchaseItem 상세 정보 로그 출력
        for (var i = 0; i < purchaseItems.length; i++) {
          final item = purchaseItems[i];
          AppLogger.d('--- PurchaseItem[$i] 상세 정보 ---');
          AppLogger.d('  PurchaseItem ID: ${item.id}');
          AppLogger.d('  Product ID (pid): ${item.pid}');
          AppLogger.d('  Purchase ID (pcid): ${item.pcid}');
          AppLogger.d('  Quantity (pcQuantity): ${item.pcQuantity}');
          AppLogger.d('  Status (pcStatus): "${item.pcStatus}"');
          AppLogger.d('-' * 50);
        }
        AppLogger.d('=' * 50);

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

        // 주문 상태 결정 (DB에 저장된 PurchaseItem 상태 기반)
        final orderStatus = _determineOrderStatus(purchaseItems, purchase);

        AppLogger.d('주문 상태: $orderStatus');

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _orderStatus = orderStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('주문 상세 로드 실패', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// PurchaseItem 목록을 기반으로 주문 전체 상태를 결정하는 함수
  /// 관리자 화면에서는 실제 상태를 그대로 표시 (고객 화면과 달리 변환하지 않음)
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

    // 상태 결정: 실제 상태를 그대로 반환 (관리자는 실제 상태를 확인해야 함)
    int displayStatus;
    if (allSameStatus) {
      displayStatus = firstStatus;
    } else {
      // 상태가 다르면 가장 낮은 상태를 반환 (보수적 접근)
      displayStatus = statusNumbers.reduce((a, b) => a < b ? a : b);
    }

    // 실제 상태를 그대로 반환 (관리자 화면에서는 변환하지 않음)
    if (displayStatus >= 0 && displayStatus <= 5) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_purchase == null || _customer == null) {
      return const Center(
        child: Text('주문 정보를 불러올 수 없습니다.'),
      );
    }

    // 주문 상품들의 총 가격 계산
    final totalPrice = _orderItems.fold<int>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // 상태에 따라 버튼 텍스트 결정
    // 관리자 화면은 읽기 전용이므로 상태에 맞는 텍스트를 표시
    // 제품 준비 완료 상태일 때만 "픽업 준비 완료", 그 외에는 현재 상태 표시
    String buttonText;
    final statusNum = _parseStatusToNumber(_orderStatus);
    if (statusNum == 1) {
      // 제품 준비 완료 상태: 픽업 준비 완료 버튼 (비활성화) - 관리자 관점
      buttonText = '픽업 준비 완료';
    } else {
      // 그 외 상태: 현재 상태 텍스트 표시 (제품 수령 완료, 제품 준비 중, 반품 신청 등)
      buttonText = _orderStatus;
    }
    
    AppLogger.d('버튼 텍스트 결정: orderStatus="$_orderStatus", statusNum=$statusNum, buttonText="$buttonText"');

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // 주문 ID 및 상태 표시
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
        CustomText('주문 상품들', fontSize: 18, fontWeight: FontWeight.bold),

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
              child: CustomRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 상품명 (가장 넓은 영역)
                  Expanded(
                    flex: 2,
                    child: CustomText(
                      item.productName,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  // 사이즈 표시
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      '${item.size}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 색상 표시
                  SizedBox(
                    width: 60,
                    child: CustomText(
                      item.color,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 수량 표시
                  SizedBox(
                    width: 40,
                    child: CustomText(
                      '${item.quantity}',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 가격 표시 (오른쪽 정렬)
                  SizedBox(
                    width: 100,
                    child: CustomText(
                      '${formatPrice(item.price * item.quantity)}원',
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),

        // 총 가격 표시 (오른쪽 정렬)
        CustomRow(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              '총 가격: ${formatPrice(totalPrice)}원',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),

        // 픽업 완료 버튼 (읽기 전용 - 비활성화)
        IgnorePointer(
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: CustomText(
                buttonText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

