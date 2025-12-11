import 'package:flutter/material.dart';
import 'custom/custom.dart';

// 관리자 모바일 접근 차단 안내 화면

class AdminMobileBlockScreen extends StatelessWidget {
  const AdminMobileBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '접근 제한', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: CustomPadding(
            padding: const EdgeInsets.all(16),
            child: CustomColumn(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                // 경고 아이콘 또는 이미지
                Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),

                // 안내 메시지 카드
                CustomCard(
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      CustomText(
                        '모바일 접근 제한',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      CustomText(
                        '관리자 기능은 태블릿에서만 사용 가능합니다.',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),

                      CustomText(
                        '관리자 계정으로 로그인하시려면 태블릿 기기에서 접속해주세요.',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 안내 사항
                CustomCard(
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      CustomText(
                        '안내 사항',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        '• 관리자 기능은 보안상의 이유로 태블릿에서만 제공됩니다.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      CustomText(
                        '• 일반 사용자는 모바일에서도 모든 기능을 이용할 수 있습니다.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      CustomText(
                        '• 문의사항이 있으시면 고객센터로 연락해주세요.',
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 확인 버튼
                CustomButton(
                  btnText: '확인',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _handleConfirm(context),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----Function Start----

  // 확인 버튼 클릭 처리
  void _handleConfirm(BuildContext context) {
    // TODO: 앱 종료 또는 이전 화면으로 이동
    Navigator.of(context).pop();
  }

  //----Function End----
}
