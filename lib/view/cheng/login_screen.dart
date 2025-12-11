import 'package:flutter/material.dart';
import 'custom/custom.dart';

import 'signup_screen.dart';

// 로그인 화면

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>();

  // 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();

  // 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  // 자동 로그인 체크박스 상태
  bool _rememberMe = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque, // 자식 위젯이 터치를 소비해도 onTap이 호출되도록 설정
      child: Scaffold(
        appBar: CustomAppBar(title: '로그인', centerTitle: true),
        body: SafeArea(
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 또는 타이틀 영역
              CustomPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 48,
                ),
                child: CustomText(
                  '신발 가게',
                  fontSize: 32,
                  textAlign: TextAlign.center,
                ),
              ),

              // 입력 필드 영역
              CustomPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: CustomColumn(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      // 아이디 입력 필드
                      CustomTextField(
                        controller: _idController,
                        labelText: '아이디',
                        hintText: '아이디를 입력하세요',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person),
                        required: true,
                        requiredMessage: '아이디를 입력해주세요',
                      ),

                      // 비밀번호 입력 필드
                      CustomTextField(
                        controller: _passwordController,
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock),
                        required: true,
                        requiredMessage: '비밀번호를 입력해주세요',
                      ),
                      /*
                      // 자동 로그인 체크박스
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: _handleRememberMeChanged,
                          ),
                          CustomText(
                            '자동 로그인',
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ],
                      ),
                      */
                      const SizedBox(height: 24),

                      // 로그인 버튼
                      CustomButton(
                        btnText: '로그인',
                        buttonType: ButtonType.elevated,
                        onCallBack: _handleLogin,
                        minimumSize: const Size(double.infinity, 56),
                      ),

                      const SizedBox(height: 16),

                      // 회원가입 버튼
                      CustomButton(
                        btnText: '회원가입',
                        buttonType: ButtonType.outlined,
                        onCallBack: _navigateToSignUp,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //----Function Start----

  // 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // 자동 로그인 체크박스 변경 처리
  void _handleRememberMeChanged(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  // 로그인 버튼 클릭 처리
  void _handleLogin() {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    // Form 검증
    if (_formKey.currentState!.validate()) {
      final id = _idController.text.trim();
      final password = _passwordController.text.trim();

      // TODO: 로그인 로직 구현
      print('로그인 시도: $id, 비밀번호: ${password.isNotEmpty ? "입력됨" : "없음"}');
    }
  }

  // 회원가입 화면으로 이동
  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    ).then((_) {
      // 뒤로 가기 시 로그인 화면으로 돌아옴
    });
  }

  //----Function End----
}
