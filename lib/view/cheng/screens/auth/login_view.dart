// Dart SDK imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Third-party package imports
import 'package:get/get.dart';

// Local imports - Core
import '../../../../Restitutor_custom/dao_custom.dart';
import '../../../../config.dart' as config;
import '../../../../model/customer.dart';
import '../../../../model/login_history.dart';

// Local imports - Custom widgets & utilities
import '../../custom/custom.dart';

// Local imports - Screens
import '../customer/search_view.dart' as cheng_search;
import 'signup_view.dart';
import 'admin_login_view.dart';
import '../admin/admin_mobile_block_view.dart';
import '../../test_navigation_page.dart';

// Local imports - Utils
import '../../utils/admin_tablet_utils.dart';

// Local imports - Storage
import '../../storage/user_storage.dart';
// 로그인 화면

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>(debugLabel: 'LoginForm');

  // 아이디 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();

  // 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();
  
  final customerDAO = RDAO<Customer>(
    dbName: dbName,
    tableName: config.kTableCustomer,
    dVersion: dVersion,
    fromMap: Customer.fromMap,
  );
  final loginHistoryDAO = RDAO<LoginHistory>(
    dbName: dbName,
    tableName: config.kTableLoginHistory,
    dVersion: dVersion,
    fromMap: LoginHistory.fromMap,
  );

  // 관리자 진입을 위한 탭 카운터 및 타이머
  int _adminTapCount = 0; // 로고 탭 횟수
  Timer? _adminTapTimer; // 2초 타이머

  @override
  void initState() {
    super.initState();
    // DB 초기화는 main.dart에서 이미 수행되므로 여기서는 호출하지 않습니다.
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    // 타이머 정리
    _adminTapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque, // 자식 위젯이 터치를 소비해도 onTap이 호출되도록 설정
      child: Scaffold(
        backgroundColor: const Color(0xFFD9D9D9),
        appBar: CustomAppBar(
          title: '로그인',
          centerTitle: true,
          titleTextStyle: config.rLabel,
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: CustomColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // 로고 이미지 영역
              // 로고를 탭하면 관리자 진입 모드가 활성화됩니다 (2초 안에 5번 탭)
              CustomPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: GestureDetector(
                  onTap: _handleLogoTap,
                  child: Image.asset(
                    'images/logo.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지 로드 실패 시 텍스트로 대체
                      return CustomText(
                        'SHOE KING',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
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
                      // 이메일 또는 전화번호 입력 필드
                      CustomTextField(
                        controller: _idController,
                        labelText: '이메일 또는 전화번호',
                        hintText: '이메일 또는 전화번호를 입력하세요',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(Icons.person),
                        required: true,
                        requiredMessage: '이메일 또는 전화번호를 입력해주세요',
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

                      const SizedBox(height: 16),

                      // 테스트 페이지로 이동 버튼 (임시)
                      CustomButton(
                        btnText: '테스트 페이지로 이동',
                        buttonType: ButtonType.outlined,
                        onCallBack: _navigateToTestPage,
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
      ),
    );
  }

  //----Function Start----

  // 키보드 내리기
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 로그인 성공 후 처리 (중복 코드 제거)
  void _handleLoginSuccess(Customer customer) {
    UserStorage.saveUser(customer);
    Get.snackbar(
      '로그인 성공',
      '${customer.cName}님 환영합니다!',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAll(() => const cheng_search.SearchView());
  }

  /// 로그인 차단 처리 (중복 코드 제거)
  void _blockLogin(String message) {
    CustomDialog.show(
      context,
      title: '로그인 불가',
      message: message,
      type: DialogType.single,
      confirmText: '확인',
    );
  }

  /// 상태 키 변환 함수
  /// DB에 숫자(0, 1, 2) 또는 문자열("0", "1", "2", "활동 회원", "휴면 회원", "탈퇴 회원")로 저장될 수 있음
  int? _parseStatusKey(String currentStatus) {
    for (var entry in config.loginStatus.entries) {
      final key = entry.key;
      final value = entry.value;
      final keyAsString = key.toString();
      
      if (currentStatus == keyAsString || 
          currentStatus == value || 
          currentStatus == key.toString() ||
          (int.tryParse(currentStatus) != null && int.parse(currentStatus) == key)) {
        return key;
      }
    }
    return null;
  }

  /// 6개월 미접속 체크 및 휴면 회원 처리
  /// 반환값: true면 휴면 처리되어 로그인 차단, false면 정상 진행
  Future<bool> _checkDormantAccount(LoginHistory loginHistory, Customer customer) async {
    try {
      final loginTimeStr = loginHistory.loginTime;
      DateTime lastLoginDateTime;
      
      if (loginTimeStr.length == 16) {
        lastLoginDateTime = DateTime.parse('$loginTimeStr:00');
      } else {
        lastLoginDateTime = DateTime.parse(loginTimeStr);
      }
      
      final now = DateTime.now();
      final daysDifference = now.difference(lastLoginDateTime).inDays;
      
      AppLogger.d('마지막 로그인: $lastLoginDateTime, 현재: $now, 차이: $daysDifference일', tag: 'Login');
      
      if (daysDifference >= 180) {
        AppLogger.w('6개월 이상 미접속 - 휴면 회원 처리', tag: 'Login', error: 'Customer ID: ${customer.id}');
        
        await loginHistoryDAO.updateK(
          {'lStatus': config.loginStatus[1] as String},
          {'cid': customer.id},
        );
        
        _blockLogin('장기간 미접속으로 휴면 회원 처리 되었습니다.');
        return true; // 로그인 차단
      }
      return false; // 정상 진행
    } catch (e, stackTrace) {
      AppLogger.e('마지막 로그인 시간 파싱 실패', tag: 'Login', error: e, stackTrace: stackTrace);
      return false; // 에러 발생 시 로그인 진행
    }
  }

  /// 로그인 시간 업데이트
  Future<void> _updateLoginTime(Customer customer) async {
    try {
      final currentTime = CustomCommonUtil.formatDate(
        DateTime.now(),
        'yyyy-MM-dd HH:mm',
      );
      
      await loginHistoryDAO.updateK(
        {'loginTime': currentTime},
        {'cid': customer.id},
      );
      
      AppLogger.d('로그인 히스토리 업데이트 성공 - Customer ID: ${customer.id}', tag: 'Login');
    } catch (e, stackTrace) {
      AppLogger.e('로그인 히스토리 업데이트 실패', tag: 'Login', error: e, stackTrace: stackTrace);
    }
  }

  /// 상태별 로그인 처리
  Future<bool> _handleStatusBasedLogin(int? statusKey, String currentStatus, Customer customer, LoginHistory loginHistory) async {
    if (statusKey == 0) {
      // 활동 회원 - 6개월 미접속 체크
      final isDormant = await _checkDormantAccount(loginHistory, customer);
      if (isDormant) {
        return false; // 로그인 차단
      }
      
      await _updateLoginTime(customer);
      _handleLoginSuccess(customer);
      return true;
    } else if (statusKey == 1) {
      // 휴면 회원
      AppLogger.w('휴면 회원 로그인 시도 - Customer ID: ${customer.id}', tag: 'Login');
      _blockLogin('휴면 회원입니다.');
      return false;
    } else if (statusKey == 2) {
      // 탈퇴 회원
      AppLogger.w('탈퇴 회원 로그인 시도 - Customer ID: ${customer.id}', tag: 'Login');
      _blockLogin('탈퇴 회원입니다.');
      return false;
    } else if (statusKey == null) {
      // statusKey가 null인 경우 - 직접 문자열 비교
      if (currentStatus == '탈퇴 회원' || currentStatus == '2' || currentStatus.contains('탈퇴')) {
        AppLogger.w('탈퇴 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}', tag: 'Login');
        _blockLogin('탈퇴 회원입니다.');
        return false;
      } else if (currentStatus == '휴면 회원' || currentStatus == '1' || currentStatus.contains('휴면')) {
        AppLogger.w('휴면 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}', tag: 'Login');
        _blockLogin('휴면 회원입니다.');
        return false;
      } else if (currentStatus == '활동 회원' || currentStatus == '0' || currentStatus.contains('활동')) {
        // 활동 회원으로 판단 - 정상 로그인 처리
        await _updateLoginTime(customer);
        _handleLoginSuccess(customer);
        return true;
      } else {
        // 알 수 없는 상태
        AppLogger.e('알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: "$currentStatus"', tag: 'Login');
        Get.snackbar(
          '오류',
          '로그인 상태를 확인할 수 없습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return false;
      }
    } else {
      // 알 수 없는 상태 (statusKey가 0, 1, 2가 아닌 경우)
      AppLogger.e('알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: "$currentStatus", StatusKey: $statusKey', tag: 'Login');
      Get.snackbar(
        '오류',
        '로그인 상태를 확인할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }
  }

  /// 로고 탭 처리 함수
  /// 로고를 탭하면 관리자 진입 모드가 활성화됩니다.
  /// 2초 안에 5번 탭하면 태블릿 여부를 확인한 후:
  /// - 태블릿이면 관리자 로그인 페이지로 이동
  /// - 모바일이면 모바일 차단 화면으로 이동
  /// 2초를 넘어가면 타이머가 정지되고 카운터가 리셋됩니다.
  void _handleLogoTap() {
    // 기존 타이머가 실행 중이면 취소
    _adminTapTimer?.cancel();

    // 카운터 증가
    setState(() {
      _adminTapCount++;
    });

    // 2초 안에 5번 탭했는지 확인
    if (_adminTapCount >= 5) {
      // 카운터 및 타이머 리셋
      _adminTapCount = 0;
      _adminTapTimer?.cancel();

      // 태블릿 여부 확인
      final isTabletDevice = isTablet(context);
      
      if (isTabletDevice) {
        // 태블릿이면 관리자 로그인 페이지로 이동
        Get.to(() => const AdminLoginView());
      } else {
        // 모바일이면 모바일 차단 화면으로 이동
        Get.to(() => const AdminMobileBlockView());
      }
      return;
    }

    // 2초 타이머 시작
    _adminTapTimer = Timer(const Duration(seconds: 2), () {
      // 2초가 지나면 타이머 정지 및 카운터 리셋
      _adminTapTimer?.cancel();
      setState(() {
        _adminTapCount = 0;
      });
    });
  }

  /// 로그인 버튼 클릭 처리 함수
  /// 이메일 또는 전화번호와 비밀번호를 검증하고 고객 DB에서 조회하여 로그인을 처리합니다.
  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final input = _idController.text.trim();
    final password = _passwordController.text.trim();
    final isEmail = CustomCommonUtil.isEmail(input);
    
    final queryMap = isEmail
        ? {'cEmail': input, 'cPassword': password}
        : {'cPhoneNumber': input, 'cPassword': password};

    customerDAO.queryK(queryMap).then((customers) async {
      if (customers.isEmpty) {
        AppLogger.d('로그인 실패 - 입력값과 일치하는 고객 정보 없음', tag: 'Login');
        Get.snackbar(
          '로그인 실패',
          '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      final customer = customers.first;
      
      if (customer.id == null) {
        AppLogger.e('Customer ID가 null입니다 - 로그인 처리 불가', tag: 'Login');
        Get.snackbar(
          '오류',
          '로그인 처리 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
        return;
      }

      AppLogger.d('로그인 성공 - Customer ID: ${customer.id}, 이름: ${customer.cName}', tag: 'Login');
      
      try {
        final loginHistories = await loginHistoryDAO.queryK({'cid': customer.id});
        
        if (loginHistories.isNotEmpty) {
          final loginHistory = loginHistories.first;
          final currentStatus = loginHistory.lStatus;
          final statusKey = _parseStatusKey(currentStatus);
          
          await _handleStatusBasedLogin(statusKey, currentStatus, customer, loginHistory);
        } else {
          // 로그인 히스토리가 없으면 신규 생성
          AppLogger.d('로그인 히스토리가 없음 - 신규 생성 시도', tag: 'Login');
          await _createLoginHistory(customer, loginHistoryDAO);
          _handleLoginSuccess(customer);
        }
      } catch (e, stackTrace) {
        // EMPTY 예외는 로그인 히스토리가 없다는 의미이므로 정상적인 경우
        if (e.toString().contains('EMPTY')) {
          AppLogger.i('로그인 히스토리가 없음 (정상) - Customer ID: ${customer.id}', tag: 'Login');
          await _createLoginHistory(customer, loginHistoryDAO);
        } else {
          AppLogger.e('로그인 히스토리 조회 중 예상치 못한 에러 발생', tag: 'Login', error: e, stackTrace: stackTrace);
          await _createLoginHistory(customer, loginHistoryDAO);
        }
        
        _handleLoginSuccess(customer);
      }
    }).catchError((error, stackTrace) {
      AppLogger.e('로그인 처리 중 예외 발생', tag: 'Login', error: error, stackTrace: stackTrace);
      Get.snackbar(
        '오류',
        '로그인 중 오류가 발생했습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    });
  }

  /// 로그인 히스토리 생성
  Future<void> _createLoginHistory(Customer customer, RDAO<LoginHistory> loginHistoryDAO) async {
    final currentTime = CustomCommonUtil.formatDate(
      DateTime.now(),
      'yyyy-MM-dd HH:mm',
    );
    
    final double dVersion = config.kVersion.toDouble();
    
    final newLoginHistory = LoginHistory(
      cid: customer.id,
      loginTime: currentTime,
      lStatus: config.loginStatus[0] as String,
      lVersion: dVersion,
      lAddress: '',
      lPaymentMethod: '',
    );
    
    try {
      final loginHistoryMap = newLoginHistory.toMap();
      await loginHistoryDAO.insertK(loginHistoryMap);
      AppLogger.d('로그인 히스토리 생성 성공 - Customer ID: ${customer.id}', tag: 'Login');
    } catch (e, stackTrace) {
      AppLogger.e('로그인 히스토리 생성 실패', tag: 'Login', error: e, stackTrace: stackTrace);
      // 로그인 히스토리 생성 실패는 로그인 성공에 영향을 주지 않음
    }
  }

  // 회원가입 화면으로 이동
  void _navigateToSignUp() {
    Get.to(() => const SignUpView());
  }

  /// 테스트 페이지로 이동하는 함수 (임시)
  void _navigateToTestPage() {
    Get.to(() => const TestNavigationPage());
  }
  
  //----Function End----
}
