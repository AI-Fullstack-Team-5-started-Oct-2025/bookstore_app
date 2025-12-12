import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../customer/customer_info_card.dart';

/// 반품 주문 상세 정보 뷰
/// 반품 관리 화면의 우측에 표시되는 반품 주문 상세 정보를 보여주는 위젯입니다.
/// 주문자 정보, 반품 상품 목록, 반품 확인 버튼을 포함합니다.
class ReturnOrderDetailView extends StatelessWidget {
  /// 주문 ID (주문 번호)
  final String orderId;

  const ReturnOrderDetailView({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: DB에서 반품 주문 상세 정보 가져오기
    // 임시 데이터 - 실제 구현 시 DB에서 조회한 데이터로 교체 필요
    final customerInfo = {
      'name': '홍길동',
      'phone': '010-1234-5678',
      'email': 'hong@example.com',
    };

    // 반품 상품 목록 (임시 데이터)
    final returnItems = [
      {'productName': '나이키 에어맥스', 'size': '265', 'color': '블랙', 'quantity': 1},
      {
        'productName': '아디다스 스탠스미스',
        'size': '270',
        'color': '화이트',
        'quantity': 2,
      },
    ];

    return CustomColumn(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // 주문자 상세 정보 카드
        CustomerInfoCard(
          name: customerInfo['name'] as String,
          phone: customerInfo['phone'] as String,
          email: customerInfo['email'] as String,
        ),

        // 반품 상품들
        CustomText('반품 상품들', fontSize: 18, fontWeight: FontWeight.bold),

        // 반품 상품 리스트 (각 상품을 카드로 표시)
        ...returnItems.map((item) {
          return CustomCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            child: CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 상품명 (가장 넓은 영역, 굵은 글씨)
                Expanded(
                  flex: 2,
                  child: CustomText(
                    item['productName'] as String,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 사이즈 표시
                SizedBox(
                  width: 60,
                  child: CustomText(
                    '사이즈: ${item['size']}',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 색상 표시
                SizedBox(
                  width: 60,
                  child: CustomText(
                    item['color'] as String,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 수량 표시
                SizedBox(
                  width: 40,
                  child: CustomText(
                    '${item['quantity']}개',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 반품 확인 버튼 (각 상품별로 반품 확인 가능)
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    btnText: '반품 확인',
                    buttonType: ButtonType.elevated,
                    onCallBack: () {
                      // TODO: 반품 확인 함수 호출 - DB 업데이트 및 상태 변경 필요
                      print('반품 확인: ${item['productName']}');
                    },
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

