import 'package:flutter/material.dart';
import 'custom/custom.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'admin_mobile_block_screen.dart';

// 네비게이션 테스트 페이지

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '네비게이션 테스트', centerTitle: true),
      body: SafeArea(
        child: CustomPadding(
          padding: const EdgeInsets.all(24),
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              CustomText(
                '페이지 이동 테스트',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                btnText: '로그인 화면',
                buttonType: ButtonType.elevated,
                onCallBack: () => _navigateToLogin(context),
                minimumSize: const Size(double.infinity, 56),
              ),
              CustomButton(
                btnText: '회원가입 화면',
                buttonType: ButtonType.elevated,
                onCallBack: () => _navigateToSignUp(context),
                minimumSize: const Size(double.infinity, 56),
              ),
              CustomButton(
                btnText: '관리자 모바일 차단 화면',
                buttonType: ButtonType.elevated,
                onCallBack: () => _navigateToAdminBlock(context),
                minimumSize: const Size(double.infinity, 56),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //----Function Start----

  // 로그인 화면으로 이동
  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // 회원가입 화면으로 이동
  void _navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  // 관리자 모바일 차단 화면으로 이동
  void _navigateToAdminBlock(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminMobileBlockScreen()),
    );
  }

  //----Function End----
}
