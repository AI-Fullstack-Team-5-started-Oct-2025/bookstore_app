import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom/custom.dart';
import 'customer_sub_dir/customer_info_card.dart';

/// 고객용 수령 완료 상세 화면
/// 모바일 세로 화면에 최적화된 수령 완료 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록을 포함하며, 각 상품별로 반품 버튼이 있습니다.
class ReturnDetailScreen extends StatefulWidget {
  /// 주문 ID (주문 번호)
  final String orderId;

  const ReturnDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {

  // 각 상품의 반품 상태를 관리하는 맵
  // key: 상품 인덱스 또는 상품 ID, value: 반품 상태 ('반품', '반품 완료')
  final Map<int, String> _productReturnStatus = {};

  @override
  Widget build(BuildContext context) {
    // TODO: DB에서 수령 완료 주문 상세 정보 가져오기
    // 임시 데이터 - 실제 구현 시 DB에서 조회한 데이터로 교체 필요
    // 현재 로그인한 사용자의 주문인지 확인 필요
    final customerInfo = {
      'name': '홍길동',
      'phone': '010-1234-5678',
      'email': 'hong@example.com',
    };

    // 주문 상품 목록 (임시 데이터)
    // TODO: DB에서 가져온 상품별 반품 상태를 _productReturnStatus에 초기화해야 함
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

    // 주문 상품들의 총 가격 계산
    final totalPrice = orderItems.fold<int>(
      0,
      (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: '주문 상세',
        centerTitle: true,
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
                  child: CustomText(
                    '주문번호: ${widget.orderId}',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // 주문자 상세 정보 카드
                CustomerInfoCard(
                  name: customerInfo['name'] as String,
                  phone: customerInfo['phone'] as String,
                  email: customerInfo['email'] as String,
                ),

                // 주문 상품들 제목
                CustomText(
                  '주문 상품',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),

                // 주문 상품 리스트 (각 상품을 카드로 표시, 반품 버튼 포함)
                ...orderItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final returnStatus = _productReturnStatus[index] ?? '반품';
                  final isReturnCompleted = returnStatus == '반품 완료';

                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        // 상품명
                        CustomText(
                          item['productName'] as String,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        // 상품 정보 (사이즈, 색상, 수량)
                        CustomRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomText(
                                '사이즈: ${item['size']} | 색상: ${item['color']} | 수량: ${item['quantity']}',
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            // 가격 표시 (오른쪽 정렬)
                            CustomText(
                              '${_formatPrice(item['price'] as int)}원',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                        // 반품 버튼
                        CustomButton(
                          btnText: returnStatus,
                          buttonType: ButtonType.elevated,
                          onCallBack: isReturnCompleted
                              ? () {
                                  // 반품 완료 상태면 아무 동작 안 함
                                }
                              : () {
                                  // 반품 버튼 클릭 시 DB 업데이트 및 상태 변경
                                  _handleReturnRequest(index, item);
                                },
                          minimumSize: const Size(double.infinity, 40),
                          // 반품 완료 상태면 회색으로 표시
                          backgroundColor: isReturnCompleted
                              ? Colors.grey.shade400
                              : null,
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
                        '${_formatPrice(totalPrice)}원',
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

  /// 반품 요청 처리 함수
  /// 상품의 반품 상태를 업데이트하고 DB에 저장합니다.
  void _handleReturnRequest(int productIndex, Map<String, dynamic> product) {
    // TODO: DB에 반품 상태 업데이트
    // 상품별 반품 상태를 DB에 저장해야 함
    
    // 상태 업데이트
    setState(() {
      _productReturnStatus[productIndex] = '반품 완료';
    });

    // 스낵바로 알림 표시
    Get.snackbar(
      '반품 요청',
      '${product['productName']}의 반품이 요청되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 가격 포맷팅 함수 (천 단위 콤마 추가)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

