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

/// 주문 상품 정보를 담는 클래스 (반품 상세용)
class ReturnItemInfo {
  final String productName;
  final int size;
  final String color;
  final int quantity;
  final int price;
  final int pid; // Product ID (같은 제품의 모든 PurchaseItem 찾기용)
  final String returnStatus; // 반품 상태 (pcStatus 기반)
  final List<int> purchaseItemIds; // 같은 제품의 모든 PurchaseItem ID 목록
  final String actualPcStatus; // 실제 pcStatus 값 (버튼 활성화 판단용)

  ReturnItemInfo({
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    required this.pid,
    required this.returnStatus,
    required this.purchaseItemIds,
    required this.actualPcStatus,
  });
}

/// 고객용 수령 완료 상세 화면
/// 모바일 세로 화면에 최적화된 수령 완료 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록을 포함하며, 각 상품별로 반품 버튼이 있습니다.
class ReturnDetailView extends StatefulWidget {
  /// 주문 ID (Purchase id)
  final int purchaseId;

  const ReturnDetailView({
    super.key,
    required this.purchaseId,
  });

  @override
  State<ReturnDetailView> createState() => _ReturnDetailViewState();
}

class _ReturnDetailViewState extends State<ReturnDetailView> {
  /// 로딩 상태
  bool _isLoading = true;

  /// 주문 정보
  Purchase? _purchase;

  /// 고객 정보
  Customer? _customer;

  /// 주문 상품 목록
  List<ReturnItemInfo> _orderItems = [];

  /// 반품 상태 (반품 가능 / 반품 불가)
  String _returnStatus = '반품 불가';

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

      AppLogger.d('=== 반품 상세 조회 시작 ===');
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
        final orderItemsMap = <String, ReturnItemInfo>{}; // key: "pid_size_color"
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

              // 반품 상태 결정 (pcStatus 기반)
              final statusNum = _parseStatusToNumber(item.pcStatus);
              String returnStatusText;
              if (statusNum >= 3) {
                // 반품 신청 이상 (3, 4, 5)
                returnStatusText = config.pickupStatus[statusNum] ?? '반품 신청';
              } else {
                // 반품 신청 가능 (2: 제품 수령 완료)
                returnStatusText = '반품 신청';
              }
              
              // 실제 pcStatus 값 저장 (버튼 활성화 판단용)
              final actualPcStatus = item.pcStatus;

              // 같은 제품(pid, size, color)을 구분하는 키 생성
              final itemKey = '${item.pid}_${product.size}_${productBase.pColor}';

              if (orderItemsMap.containsKey(itemKey)) {
                // 이미 같은 제품이 있으면 수량만 합산
                final existingItem = orderItemsMap[itemKey]!;
                // 같은 제품이 여러 PurchaseItem으로 나뉘어 있을 수 있으므로
                // 가장 높은 반품 상태를 유지 (반품 완료 > 반품 처리 중 > 반품 신청)
                final existingStatusNum = _parseStatusToNumber(existingItem.returnStatus);
                final currentStatusNum = _parseStatusToNumber(item.pcStatus);
                final higherStatusNum = existingStatusNum > currentStatusNum ? existingStatusNum : currentStatusNum;
                final higherStatusText = higherStatusNum >= 3
                    ? (config.pickupStatus[higherStatusNum] ?? '반품 신청')
                    : '반품 신청';

                // PurchaseItem ID 추가
                final updatedPurchaseItemIds = List<int>.from(existingItem.purchaseItemIds);
                if (item.id != null) {
                  updatedPurchaseItemIds.add(item.id!);
                }

                // 가장 높은 상태의 실제 pcStatus 유지
                final higherActualPcStatus = existingStatusNum > currentStatusNum 
                    ? existingItem.actualPcStatus 
                    : item.pcStatus;

                final updatedItem = ReturnItemInfo(
                  productName: existingItem.productName,
                  size: existingItem.size,
                  color: existingItem.color,
                  quantity: existingItem.quantity + item.pcQuantity, // 수량 합산
                  price: existingItem.price,
                  pid: existingItem.pid, // Product ID 유지
                  returnStatus: higherStatusText,
                  purchaseItemIds: updatedPurchaseItemIds,
                  actualPcStatus: higherActualPcStatus,
                );
                orderItemsMap[itemKey] = updatedItem;
                AppLogger.d('기존 ReturnItem 수량 합산: ${existingItem.productName}, 기존 수량=${existingItem.quantity}, 추가 수량=${item.pcQuantity}, 총 수량=${updatedItem.quantity}');
              } else {
                // 새로운 제품이면 추가
                final purchaseItemIdsList = <int>[];
                if (item.id != null) {
                  purchaseItemIdsList.add(item.id!);
                }
                final returnItem = ReturnItemInfo(
                  productName: productBase.pName,
                  size: product.size,
                  color: productBase.pColor,
                  quantity: item.pcQuantity,
                  price: product.basePrice,
                  pid: item.pid, // Product ID 저장
                  returnStatus: returnStatusText,
                  purchaseItemIds: purchaseItemIdsList,
                  actualPcStatus: actualPcStatus,
                );
                orderItemsMap[itemKey] = returnItem;
                AppLogger.d('ReturnItem 추가: ${returnItem.productName}, 사이즈=${returnItem.size}, 색상=${returnItem.color}, 수량=${returnItem.quantity}, 가격=${returnItem.price}, 반품상태=${returnItem.returnStatus}');
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
        AppLogger.d('ReturnItem 개수: ${orderItemsList.length}');
        AppLogger.d('처리된 PurchaseItem ID: $processedItemIds');

        // 반품 가능 여부 결정
        final returnStatus = _determineReturnStatus(purchaseItems, purchase);

        setState(() {
          _purchase = purchase;
          _orderItems = orderItemsList;
          _returnStatus = returnStatus;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.e('반품 상세 로드 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '주문 정보를 불러올 수 없습니다.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 반품 가능 여부를 결정하는 함수
  /// 하나라도 반품 가능하면 "반품 가능", 모두 반품 완료되면 "반품 불가" 반환
  String _determineReturnStatus(List<PurchaseItem> items, Purchase purchase) {
    if (items.isEmpty) {
      return '반품 불가';
    }

    final pickupDate = DateTime.tryParse(purchase.pickupDate);
    final now = DateTime.now();
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        appBar: CustomAppBar(
          title: Text('반품 상세', style: config.rLabel),
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
          title: Text('반품 상세', style: config.rLabel),
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
        title: Text('반품 상세', style: config.rLabel),
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
                // 주문 ID 표시 및 반품 상태
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
                      // 반품 상태 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: OrderStatusColors.getStatusColor(_returnStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          _returnStatus,
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

                // 주문 상품 리스트 (각 상품을 카드로 표시, 반품 버튼 포함)
                if (_orderItems.isEmpty)
                  CustomText(
                    '주문 상품이 없습니다.',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  )
                else
                  ..._orderItems.map((item) {
                    // 실제 pcStatus를 기반으로 반품 상태 확인
                    final statusNum = _parseStatusToNumber(item.actualPcStatus);
                    final isReturnCompleted = statusNum == 5; // 반품 완료
                    // 반품 완료(5)일 때만 pickupStatus[5] 사용, 그 외에는 '반품 신청' 텍스트 사용
                    final returnStatusText = isReturnCompleted 
                        ? (config.pickupStatus[5] ?? '반품 완료')
                        : '반품 신청';
                    
                    // pickupDate로부터 30일 경과 확인
                    bool is30DaysPassed = false;
                    if (_purchase != null) {
                      final pickupDate = DateTime.tryParse(_purchase!.pickupDate);
                      if (pickupDate != null) {
                        final daysDifference = DateTime.now().difference(pickupDate).inDays;
                        is30DaysPassed = daysDifference >= 30;
                      }
                    }
                    
                    // 버튼 활성화 여부: 
                    // - 반품 완료(5)가 아니고
                    // - 30일이 지나지 않았고
                    // - 제품 수령 완료(2) 이상인 경우
                    final isButtonEnabled = !isReturnCompleted && !is30DaysPassed && statusNum >= 2;

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
                              Expanded(
                                child: CustomText(
                                  '사이즈: ${item.size} | 색상: ${item.color} | 수량: ${item.quantity}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey.shade600,
                                ),
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
                          // 반품 버튼
                          // 30일 경과 또는 반품 완료인 경우 회색으로 표시
                          if (isButtonEnabled)
                            // 활성화된 버튼 (반품 가능)
                            CustomButton(
                              btnText: returnStatusText,
                              buttonType: ButtonType.elevated,
                              backgroundColor: Colors.red, // 반품 신청 가능: 빨간색
                              onCallBack: () => _showReturnConfirmDialog(item),
                              minimumSize: const Size(double.infinity, 40),
                            )
                          else
                            // 비활성화된 버튼 (반품 완료 또는 30일 경과) - 회색으로 표시
                            IgnorePointer(
                              child: Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: CustomText(
                                    returnStatusText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                // 총 주문 금액 표시 카드
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 반품 확인 다이얼로그 표시
  Future<void> _showReturnConfirmDialog(ReturnItemInfo item) async {
    await CustomDialog.show(
      context,
      title: '반품 확인',
      message: '${item.productName}\n정말 반품 하시겠습니까?',
      type: DialogType.dual,
      confirmText: '확인',
      cancelText: '취소',
      onConfirm: () async {
        await _handleReturnComplete(item);
      },
      onCancel: () {
        // 취소 시 아무 작업도 하지 않음
      },
    );
  }

  /// 반품 완료 처리 함수
  /// 같은 제품(pid, size, color)의 모든 PurchaseItem의 pcStatus를 반품 완료(5)로 업데이트하고,
  /// Purchase의 pickupDate를 오늘 날짜 +1로 업데이트합니다.
  Future<void> _handleReturnComplete(ReturnItemInfo item) async {
    if (_purchase?.id == null) {
      AppLogger.w('주문 정보가 없습니다.');
      return;
    }

    try {
      // 반품 완료 상태로 업데이트
      final returnCompleteStatus = config.pickupStatus[5] ?? '반품 완료';
      
      // 같은 제품의 모든 PurchaseItem을 반품 완료로 업데이트
      for (final purchaseItemId in item.purchaseItemIds) {
        await _purchaseItemDao.updateK(
          {'pcStatus': returnCompleteStatus}, // pickupStatus[5] = '반품 완료'
          {'id': purchaseItemId},
        );
        AppLogger.d('PurchaseItem ID $purchaseItemId 업데이트 완료: pcStatus = $returnCompleteStatus');
      }

      // Purchase의 pickupDate를 오늘 날짜 +1로 업데이트
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowString = tomorrow.toIso8601String().split('T').first; // YYYY-MM-DD 형식
      
      await _purchaseDao.updateK(
        {'pickupDate': tomorrowString},
        {'id': _purchase!.id},
      );
      AppLogger.d('Purchase ID ${_purchase!.id} pickupDate 업데이트 완료: $tomorrowString');

      // Purchase 정보 다시 로드
      final updatedPurchases = await _purchaseDao.queryK({'id': _purchase!.id});
      if (updatedPurchases.isNotEmpty) {
        _purchase = updatedPurchases.first;
      }

      // PurchaseItem 정보 다시 로드하여 반품 상태 재계산
      final updatedPurchaseItems = await _purchaseItemDao.queryK({'pcid': _purchase!.id});
      
      // 반품 가능 여부 재계산
      final updatedReturnStatus = _determineReturnStatus(updatedPurchaseItems, _purchase!);

      // 상태 업데이트 (해당 아이템의 returnStatus를 반품 완료로 변경)
      setState(() {
        final index = _orderItems.indexWhere((i) => 
          i.pid == item.pid && i.size == item.size && i.color == item.color);
        if (index != -1) {
          _orderItems[index] = ReturnItemInfo(
            productName: item.productName,
            size: item.size,
            color: item.color,
            quantity: item.quantity,
            price: item.price,
            pid: item.pid,
            returnStatus: returnCompleteStatus,
            purchaseItemIds: item.purchaseItemIds,
            actualPcStatus: returnCompleteStatus, // 실제 pcStatus도 업데이트
          );
        }
        // 상단 반품 상태 표시 갱신
        _returnStatus = updatedReturnStatus;
      });

      // 스낵바로 알림 표시
      Get.snackbar(
        '반품 완료',
        '${item.productName}의 반품이 완료되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      AppLogger.e('반품 완료 처리 실패', error: e, stackTrace: stackTrace);
      Get.snackbar('오류', '반품 완료 처리에 실패했습니다.');
    }
  }
}


