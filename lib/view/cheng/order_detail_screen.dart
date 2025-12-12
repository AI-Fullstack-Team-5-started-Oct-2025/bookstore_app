import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config.dart' as config;
import 'custom/custom.dart';
import 'customer_sub_dir/customer_info_card.dart';
import 'employee_sub_dir/order_utils.dart';

/// 고객용 주문 상세 화면
/// 모바일 세로 화면에 최적화된 주문 상세 정보 화면입니다.
/// 주문자 정보, 주문 상품 목록, 총 가격, 픽업 완료 버튼을 포함합니다.
class OrderDetailScreen extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: DB에서 주문 상세 정보 가져오기
    // 임시 데이터 - 실제 구현 시 DB에서 조회한 데이터로 교체 필요
    // 현재 로그인한 사용자의 주문인지 확인 필요
    final customerInfo = {
      'name': '홍길동',
      'phone': '010-1234-5678',
      'email': 'hong@example.com',
    };

    // 주문 상품 목록 (임시 데이터)
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

    // 주문 상태 (임시 데이터)
    final orderStatus = '준비완료';

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
                        '주문번호: $orderId',
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
                          color: _getStatusColor(orderStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          orderStatus,
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

                // 주문 상품 리스트 (각 상품을 카드로 표시)
                ...orderItems.map((item) {
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
                            CustomText(
                              '사이즈: ${item['size']} | 색상: ${item['color']} | 수량: ${item['quantity']}',
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade600,
                            ),
                            // 가격 표시 (오른쪽 정렬)
                            CustomText(
                              '${formatPrice(item['price'] as int)}원',
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

                // 픽업 완료 버튼 (준비완료 상태일 때만 표시)
                if (orderStatus == '준비완료')
                  CustomButton(
                    btnText: '픽업 완료',
                    buttonType: ButtonType.elevated,
                    onCallBack: () {
                      // TODO: 픽업 완료 함수 호출 - DB 업데이트 및 상태 변경 필요
                      Get.snackbar(
                        '픽업 완료',
                        '픽업이 완료되었습니다.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      // 상태 업데이트 후 이전 페이지로 돌아가기
                      Get.back();
                    },
                    minimumSize: const Size(double.infinity, 50),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 주문 상태에 따른 색상 반환
  Color _getStatusColor(String status) {
    switch (status) {
      case '대기중':
        return Colors.orange;
      case '준비완료':
        return Colors.blue;
      case '픽업완료':
        return Colors.green;
      case '반품요청':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

