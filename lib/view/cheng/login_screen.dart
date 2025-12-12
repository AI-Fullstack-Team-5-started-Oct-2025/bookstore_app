import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../Restitutor_custom/dao_custom.dart';
import '../../config.dart' as config;
import '../../model/customer.dart';
import '../../model/login_history.dart';
import '../customer/search_view.dart';
import 'custom/custom.dart';
import 'custom/custom_common_util.dart';

import 'signup_screen.dart';
import 'admin_login.dart';
import 'admin_mobile_block_screen.dart';
import 'employee_sub_dir/admin_tablet_utils.dart';
import 'test_navigation_page.dart';
import 'package:bookstore_app/db_setting.dart';
import 'customer_sub_dir/user_storage.dart';
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
  
   final DbSetting dbSetting = DbSetting();
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
      final size = MediaQuery.of(context).size;
      final shortestSide = size.shortestSide;
      final isTabletDevice = isTablet(context);
      
      // 디버깅 정보 출력
      print('태블릿 체크 - 화면 크기: ${size.width} x ${size.height}, shortestSide: $shortestSide, isTablet: $isTabletDevice');
      
      if (isTabletDevice) {
        // 태블릿이면 관리자 로그인 페이지로 이동
        Get.to(() => const AdminLoginScreen());
      } else {
        // 모바일이면 모바일 차단 화면으로 이동
        Get.to(() => const AdminMobileBlockScreen());
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
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    // Form 검증
    if (_formKey.currentState!.validate()) {
      final input = _idController.text.trim();
      final password = _passwordController.text.trim();

      // 입력값이 이메일 형식인지 정교하게 확인
      final isEmail = CustomCommonUtil.isEmail(input);
      
      // 이메일이 아니면 전화번호로 간주하여 DB 조회
      // 전화번호 형식은 다양할 수 있으므로 (010-1234-5678, 222-6789-5432 등)
      // 이메일 형식이 아닌 모든 입력값을 전화번호로 처리
      final queryMap = isEmail
          ? {'cEmail': input, 'cPassword': password}
          : {'cPhoneNumber': input, 'cPassword': password};

      customerDAO.queryK(queryMap).then((customers) async {
        if (customers.isNotEmpty) {
          // ============================================================
          // 로그인 성공 처리
          // ============================================================
          final customer = customers.first;
          print('로그인 성공: ${customer.cName}');
          
          // 해당 고객의 로그인 히스토리 조회
          if (customer.id != null) {
            try {
              final loginHistories = await loginHistoryDAO.queryK({'cid': customer.id});
              
              // 로그인 히스토리가 있는 경우
              if (loginHistories.isNotEmpty) {
                final loginHistory = loginHistories.first;
                final currentStatus = loginHistory.lStatus;
                
                // 상태 확인
                if (currentStatus == config.loginStatus[0] as String) {
                  // 활동 회원 (status 0) - 로그인 시간 갱신
                  final currentTime = CustomCommonUtil.formatDate(
                    DateTime.now(),
                    'yyyy-MM-dd HH:mm',
                  );
                  
                  await loginHistoryDAO.updateK(
                    {'loginTime': currentTime},
                    {'cid': customer.id},
                  );
                  
                  print('로그인 히스토리 갱신 완료: Customer ID ${customer.id}, 시간: $currentTime');
                  
                  // 사용자 정보를 get_storage에 저장
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  Get.offAll(() => const SearchView());
                } else if (currentStatus == config.loginStatus[1] as String) {
                  // 휴면 회원 (status 1) - 로그인 차단
                  CustomDialog.show(
                    context,
                    title: '로그인 불가',
                    message: '휴면 회원입니다.',
                    type: DialogType.single,
                    confirmText: '확인',
                  );
                } else if (currentStatus == config.loginStatus[2] as String) {
                  // 탈퇴 회원 (status 2) - 로그인 차단
                  CustomDialog.show(
                    context,
                    title: '로그인 불가',
                    message: '탈퇴 회원입니다.',
                    type: DialogType.single,
                    confirmText: '확인',
                  );
                } else {
                  // 알 수 없는 상태
                  print('알 수 없는 로그인 상태: $currentStatus');
                  Get.snackbar(
                    '오류',
                    '로그인 상태를 확인할 수 없습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                  );
                }
              } else {
                // queryK가 빈 리스트를 반환한 경우 (EMPTY 예외가 아닌 경우)
                // 로그인 히스토리가 없으면 신규 인서트
                print('로그인 히스토리를 찾을 수 없습니다: Customer ID ${customer.id}');
                print('새로운 로그인 히스토리 생성 시작');
                
                // 현재 시간을 분까지 string으로 저장 (yyyy-MM-dd HH:mm 형식)
                final currentTime = CustomCommonUtil.formatDate(
                  DateTime.now(),
                  'yyyy-MM-dd HH:mm',
                );
                
                // LoginHistory 객체 생성
                final newLoginHistory = LoginHistory(
                  cid: customer.id, // 현재 로그인한 사용자의 ID
                  loginTime: currentTime, // 현재 시간 (분까지)
                  lStatus: config.loginStatus[0] as String, // '활동 회원'
                  lVersion: 0.0, // 버전 (모델 타입상 double이지만, DB에는 빈 문자열로 저장)
                  lAddress: '', // 저장하지 않음 (빈 문자열)
                  lPaymentMethod: '', // 저장하지 않음 (빈 문자열)
                );
                
                print('  - Customer ID (cid): ${customer.id}');
                print('  - 로그인 시간 (loginTime): $currentTime');
                print('  - 상태 (lStatus): ${config.loginStatus[0]}');
                print('  - 버전 (lVersion): "" (빈 문자열로 저장)');
                
                try {
                  // lVersion을 빈 문자열로 저장하기 위해 toMap() 후 수정
                  final loginHistoryMap = newLoginHistory.toMap();
                  loginHistoryMap['lVersion'] = ''; // 빈 문자열로 저장
                  
                  print('=== 신규 로그인 히스토리 인서트 데이터 ===');
                  print('  - cid: ${loginHistoryMap['cid']}');
                  print('  - loginTime: ${loginHistoryMap['loginTime']}');
                  print('  - lStatus: ${loginHistoryMap['lStatus']}');
                  print('  - lVersion: ${loginHistoryMap['lVersion']}');
                  print('  - lAddress: ${loginHistoryMap['lAddress']}');
                  print('  - lPaymentMethod: ${loginHistoryMap['lPaymentMethod']}');
                  
                  final loginHistoryId = await loginHistoryDAO.insertK(loginHistoryMap);
                  
                  print('로그인 히스토리 생성 완료: LoginHistory ID $loginHistoryId');
                  
                  // 저장된 값을 다시 조회하여 확인
                  final insertedHistories = await loginHistoryDAO.queryK({'id': loginHistoryId});
                  if (insertedHistories.isNotEmpty) {
                    final inserted = insertedHistories.first;
                    print('=== 저장된 로그인 히스토리 확인 ===');
                    print('  - ID: ${inserted.id}');
                    print('  - cid: ${inserted.cid}');
                    print('  - loginTime: ${inserted.loginTime}');
                    print('  - lStatus: ${inserted.lStatus}');
                    print('  - lVersion: ${inserted.lVersion}');
                    print('  - lAddress: ${inserted.lAddress}');
                    print('  - lPaymentMethod: ${inserted.lPaymentMethod}');
                  }
                  
                  // 사용자 정보를 get_storage에 저장
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  Get.offAll(() => const SearchView());
                } catch (e) {
                  // 로그인 히스토리 생성 실패 시에도 일반 로그인 처리
                  print('로그인 히스토리 생성 실패: $e');
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  Get.offAll(() => const SearchView());
                }
              }
            } catch (e) {
              // EMPTY 예외는 로그인 히스토리가 없다는 의미이므로 신규 인서트
              if (e.toString().contains('EMPTY')) {
                print('로그인 히스토리가 없습니다 (EMPTY): Customer ID ${customer.id}');
                print('새로운 로그인 히스토리 생성 시작');
                
                // 현재 시간을 분까지 string으로 저장 (yyyy-MM-dd HH:mm 형식)
                final currentTime = CustomCommonUtil.formatDate(
                  DateTime.now(),
                  'yyyy-MM-dd HH:mm',
                );
                
                // LoginHistory 객체 생성
                final newLoginHistory = LoginHistory(
                  cid: customer.id, // 현재 로그인한 사용자의 ID
                  loginTime: currentTime, // 현재 시간 (분까지)
                  lStatus: config.loginStatus[0] as String, // '활동 회원'
                  lVersion: 0.0, // 버전 (모델 타입상 double이지만, DB에는 빈 문자열로 저장)
                  lAddress: '', // 저장하지 않음 (빈 문자열)
                  lPaymentMethod: '', // 저장하지 않음 (빈 문자열)
                );
                
                print('  - Customer ID (cid): ${customer.id}');
                print('  - 로그인 시간 (loginTime): $currentTime');
                print('  - 상태 (lStatus): ${config.loginStatus[0]}');
                print('  - 버전 (lVersion): "" (빈 문자열로 저장)');
                
                try {
                  // lVersion을 빈 문자열로 저장하기 위해 toMap() 후 수정
                  final loginHistoryMap = newLoginHistory.toMap();
                  loginHistoryMap['lVersion'] = ''; // 빈 문자열로 저장
                  
                  print('=== 신규 로그인 히스토리 인서트 데이터 ===');
                  print('  - cid: ${loginHistoryMap['cid']}');
                  print('  - loginTime: ${loginHistoryMap['loginTime']}');
                  print('  - lStatus: ${loginHistoryMap['lStatus']}');
                  print('  - lVersion: ${loginHistoryMap['lVersion']}');
                  print('  - lAddress: ${loginHistoryMap['lAddress']}');
                  print('  - lPaymentMethod: ${loginHistoryMap['lPaymentMethod']}');
                  
                  final loginHistoryId = await loginHistoryDAO.insertK(loginHistoryMap);
                  
                  print('로그인 히스토리 생성 완료: LoginHistory ID $loginHistoryId');
                  
                  // 저장된 값을 다시 조회하여 확인
                  final insertedHistories = await loginHistoryDAO.queryK({'id': loginHistoryId});
                  if (insertedHistories.isNotEmpty) {
                    final inserted = insertedHistories.first;
                    print('=== 저장된 로그인 히스토리 확인 ===');
                    print('  - ID: ${inserted.id}');
                    print('  - cid: ${inserted.cid}');
                    print('  - loginTime: ${inserted.loginTime}');
                    print('  - lStatus: ${inserted.lStatus}');
                    print('  - lVersion: ${inserted.lVersion}');
                    print('  - lAddress: ${inserted.lAddress}');
                    print('  - lPaymentMethod: ${inserted.lPaymentMethod}');
                  }
                  
                  // 사용자 정보를 get_storage에 저장
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  Get.offAll(() => const SearchView());
                } catch (insertError) {
                  // 로그인 히스토리 생성 실패 시에도 일반 로그인 처리
                  print('로그인 히스토리 생성 실패: $insertError');
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  Get.offAll(() => const SearchView());
                }
              } else {
                // EMPTY가 아닌 다른 에러인 경우
                print('로그인 히스토리 조회 실패: $e');
                UserStorage.saveUser(customer);
                
                Get.snackbar(
                  '로그인 성공',
                  '${customer.cName}님 환영합니다!',
                  snackPosition: SnackPosition.BOTTOM,
                );

                Get.offAll(() => const SearchView());
              }
            }
          } else {
            // Customer ID가 없는 경우 (이론적으로 발생하지 않아야 함)
            print('Customer ID가 없습니다.');
            Get.snackbar(
              '오류',
              '로그인 처리 중 오류가 발생했습니다.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
            );
          }
        } else {
          // 로그인 실패
          Get.snackbar(
            '로그인 실패',
            '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }).catchError((error) {
        // 에러 처리
        print('로그인 에러: $error');
        Get.snackbar(
          '오류',
          '로그인 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      });
    }
  }

  // 회원가입 화면으로 이동
  void _navigateToSignUp() {
    Get.to(() => const SignUpScreen());
  }

  /// 테스트 페이지로 이동하는 함수 (임시)
  void _navigateToTestPage() {
    Get.to(() => const TestNavigationPage());
  }

  //----Function End----
}
