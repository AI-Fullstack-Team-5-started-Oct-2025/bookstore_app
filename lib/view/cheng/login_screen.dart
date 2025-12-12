import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../Restitutor_custom/dao_custom.dart';
import '../../config.dart' as config;
import '../../model/customer.dart';
import '../../model/login_history.dart';
import 'search_view.dart' as cheng_search; // 임시: cheng 폴더의 search_view 사용
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
      final isTabletDevice = isTablet(context);
      
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
          // 로그인 성공 처리
          final customer = customers.first;
          
          // 해당 고객의 로그인 히스토리 조회
          if (customer.id != null) {
            print('[DEBUG] 로그인 성공 - Customer ID: ${customer.id}, 이름: ${customer.cName}');
            try {
              print('[DEBUG] 로그인 히스토리 조회 시작 - Customer ID: ${customer.id}');
              final loginHistories = await loginHistoryDAO.queryK({'cid': customer.id});
              print('[DEBUG] 로그인 히스토리 조회 완료 - 조회된 히스토리 수: ${loginHistories.length}');
              
              // 로그인 히스토리가 있는 경우
              if (loginHistories.isNotEmpty) {
                final loginHistory = loginHistories.first;
                
                // LoginHistory 정보 상세 출력
                print('[DEBUG] ========== LoginHistory 조회 성공 ==========');
                print('[DEBUG] 조회된 LoginHistory 수: ${loginHistories.length}');
                print('[DEBUG] --- LoginHistory 상세 정보 ---');
                print('[DEBUG] LoginHistory ID: ${loginHistory.id}');
                print('[DEBUG] Customer ID (cid): ${loginHistory.cid}');
                print('[DEBUG] 로그인 시간 (loginTime): "${loginHistory.loginTime}"');
                print('[DEBUG] 로그인 상태 (lStatus): "${loginHistory.lStatus}" (타입: ${loginHistory.lStatus.runtimeType})');
                print('[DEBUG] 버전 (lVersion): ${loginHistory.lVersion}');
                print('[DEBUG] 주소 (lAddress): "${loginHistory.lAddress}"');
                print('[DEBUG] 결제 방법 (lPaymentMethod): "${loginHistory.lPaymentMethod}"');
                print('[DEBUG] LoginHistory toMap(): ${loginHistory.toMap(includeId: true)}');
                print('[DEBUG] ===========================================');
                
                final currentStatus = loginHistory.lStatus;
                
                print('[DEBUG] ========== Status 처리 시작 ==========');
                print('[DEBUG] Customer ID: ${customer.id}');
                print('[DEBUG] 원본 currentStatus (타입: ${currentStatus.runtimeType}): "$currentStatus"');
                print('[DEBUG] currentStatus 길이: ${currentStatus.length}');
                print('[DEBUG] currentStatus 코드 유닛: ${currentStatus.codeUnits}');
                
                // 상태를 숫자 키로 변환 (0, 1, 2 중 하나)
                // DB에 숫자(0, 1, 2) 또는 문자열("0", "1", "2", "활동 회원", "휴면 회원", "탈퇴 회원")로 저장될 수 있음
                int? statusKey;
                String? statusValue;
                
                // 숫자로 변환 시도
                print('[DEBUG] --- 숫자 변환 시도 ---');
                final parsedInt = int.tryParse(currentStatus);
                print('[DEBUG] int.tryParse("$currentStatus") 결과: $parsedInt');
                
                if (parsedInt != null) {
                  statusKey = parsedInt;
                  statusValue = config.loginStatus[statusKey] as String?;
                  print('[DEBUG] ✓ 숫자 변환 성공: statusKey=$statusKey, statusValue="$statusValue"');
                } else {
                  print('[DEBUG] ✗ 숫자 변환 실패 - Map 값 비교 시도');
                  
                  // 문자열인 경우 Map의 값과 직접 비교하여 키 찾기
                  print('[DEBUG] --- Map 값 비교 시작 ---');
                  print('[DEBUG] config.loginStatus 전체: ${config.loginStatus}');
                  
                  bool foundInMap = false;
                  for (var entry in config.loginStatus.entries) {
                    print('[DEBUG] 비교 중: entry.key=${entry.key}, entry.value="${entry.value}" == currentStatus="$currentStatus"');
                    if (entry.value == currentStatus) {
                      statusKey = entry.key;
                      statusValue = entry.value;
                      foundInMap = true;
                      print('[DEBUG] ✓ Map에서 매칭 발견: statusKey=$statusKey, statusValue="$statusValue"');
                      break;
                    }
                  }
                  
                  if (!foundInMap) {
                    print('[DEBUG] ✗ Map에서 매칭 실패 - 직접 문자열 비교 시도');
                  }
                  
                  // Map에서 찾지 못한 경우, 직접 문자열 비교로 확인
                  if (statusKey == null) {
                    print('[DEBUG] --- 직접 문자열 비교 시작 ---');
                    print('[DEBUG] currentStatus == "탈퇴 회원": ${currentStatus == '탈퇴 회원'}');
                    print('[DEBUG] currentStatus == "2": ${currentStatus == '2'}');
                    print('[DEBUG] currentStatus.contains("탈퇴"): ${currentStatus.contains('탈퇴')}');
                    
                    // "탈퇴 회원" 또는 "2" 문자열 직접 확인
                    if (currentStatus == '탈퇴 회원' || currentStatus == '2' || currentStatus.contains('탈퇴')) {
                      statusKey = 2;
                      statusValue = config.loginStatus[2] as String;
                      print('[DEBUG] ✓ 탈퇴 회원으로 판단: statusKey=$statusKey, statusValue="$statusValue"');
                    } else if (currentStatus == '휴면 회원' || currentStatus == '1' || currentStatus.contains('휴면')) {
                      statusKey = 1;
                      statusValue = config.loginStatus[1] as String;
                      print('[DEBUG] ✓ 휴면 회원으로 판단: statusKey=$statusKey, statusValue="$statusValue"');
                    } else if (currentStatus == '활동 회원' || currentStatus == '0' || currentStatus.contains('활동')) {
                      statusKey = 0;
                      statusValue = config.loginStatus[0] as String;
                      print('[DEBUG] ✓ 활동 회원으로 판단: statusKey=$statusKey, statusValue="$statusValue"');
                    } else {
                      print('[DEBUG] ✗ 직접 문자열 비교도 실패 - 알 수 없는 상태');
                    }
                  }
                }
                
                print('[DEBUG] ========== Status 처리 결과 ==========');
                print('[DEBUG] 최종 statusKey: $statusKey');
                print('[DEBUG] 최종 statusValue: "$statusValue"');
                print('[DEBUG] statusKey == 0: ${statusKey == 0}');
                print('[DEBUG] statusKey == 1: ${statusKey == 1}');
                print('[DEBUG] statusKey == 2: ${statusKey == 2}');
                print('[DEBUG] statusKey == null: ${statusKey == null}');
                print('[DEBUG] =======================================');
                
                // 상태 확인 (Map의 키로 비교)
                if (statusKey == 0) {
                  // 활동 회원 (status 0) - 마지막 로그인 시간 확인 후 처리
                  
                  // 마지막 로그인 시간과 현재 시간 비교 (6개월 이상 차이 확인)
                  try {
                    // loginTime을 DateTime으로 파싱 ('yyyy-MM-dd HH:mm' 형식)
                    // 'yyyy-MM-dd HH:mm' 형식을 'yyyy-MM-dd HH:mm:ss' 형식으로 변환하여 파싱
                    final loginTimeStr = loginHistory.loginTime;
                    DateTime lastLoginDateTime;
                    
                    // 'yyyy-MM-dd HH:mm' 형식인 경우 초 단위 추가
                    if (loginTimeStr.length == 16) {
                      // 'yyyy-MM-dd HH:mm' 형식
                      lastLoginDateTime = DateTime.parse('$loginTimeStr:00');
                    } else {
                      // 이미 'yyyy-MM-dd HH:mm:ss' 형식이거나 다른 형식
                      lastLoginDateTime = DateTime.parse(loginTimeStr);
                    }
                    
                    final now = DateTime.now();
                    
                    // 6개월 전 날짜 계산 (약 180일, 정확히는 월 단위로 계산)
                    // 월 단위 계산: 현재 월에서 6을 빼고, 연도 조정
                    int targetYear = now.year;
                    int targetMonth = now.month - 6;
                    if (targetMonth <= 0) {
                      targetMonth += 12;
                      targetYear -= 1;
                    }
                    final sixMonthsAgo = DateTime(targetYear, targetMonth, now.day, now.hour, now.minute);
                    
                    print('[DEBUG] 마지막 로그인 시간 확인 - Customer ID: ${customer.id}');
                    print('[DEBUG] 마지막 로그인: $lastLoginDateTime (원본: $loginTimeStr)');
                    print('[DEBUG] 현재 시간: $now');
                    print('[DEBUG] 6개월 전: $sixMonthsAgo');
                    print('[DEBUG] 날짜 차이: ${now.difference(lastLoginDateTime).inDays}일');
                    
                    // 6개월 이상 차이나는지 확인
                    if (lastLoginDateTime.isBefore(sixMonthsAgo)) {
                      // 6개월 이상 미접속 - 휴면 회원으로 변경
                      print('[WARNING] 6개월 이상 미접속 - 휴면 회원 처리 - Customer ID: ${customer.id}');
                      print('[WARNING] 마지막 로그인: $lastLoginDateTime, 현재: $now, 차이: ${now.difference(lastLoginDateTime).inDays}일');
                      
                      // status를 1 (휴면 회원)로 업데이트
                      await loginHistoryDAO.updateK(
                        {'lStatus': config.loginStatus[1] as String},
                        {'cid': customer.id},
                      );
                      
                      print('[DEBUG] 휴면 회원으로 상태 변경 완료 - Customer ID: ${customer.id}');
                      
                      // 다이얼로그 팝업 표시
                      CustomDialog.show(
                        context,
                        title: '로그인 불가',
                        message: '장기간 미접속으로 휴면 회원 처리 되었습니다.',
                        type: DialogType.single,
                        confirmText: '확인',
                      );
                      
                      // 로그인 차단 (시간 업데이트 안 함, return으로 종료)
                      return;
                    }
                  } catch (e, stackTrace) {
                    // 날짜 파싱 실패 시 에러 로그만 출력하고 계속 진행
                    print('[ERROR] 마지막 로그인 시간 파싱 실패 - Customer ID: ${customer.id}');
                    print('[ERROR] loginTime: ${loginHistory.loginTime}');
                    print('[ERROR] 에러 메시지: $e');
                    print('[ERROR] 스택 트레이스: $stackTrace');
                    // 에러가 발생해도 로그인은 진행하도록 함
                  }
                  
                  // 6개월 미만이거나 에러 발생 시 정상 로그인 처리
                  try {
                    final currentTime = CustomCommonUtil.formatDate(
                      DateTime.now(),
                      'yyyy-MM-dd HH:mm',
                    );
                    
                    await loginHistoryDAO.updateK(
                      {'loginTime': currentTime},
                      {'cid': customer.id},
                    );
                    
                    print('[DEBUG] 로그인 히스토리 업데이트 성공 - Customer ID: ${customer.id}, LoginTime: $currentTime');
                  } catch (e, stackTrace) {
                    print('[ERROR] 로그인 히스토리 업데이트 실패 - Customer ID: ${customer.id}');
                    print('[ERROR] 에러 메시지: $e');
                    print('[ERROR] 스택 트레이스: $stackTrace');
                  }
                  
                  // 사용자 정보를 get_storage에 저장
                  UserStorage.saveUser(customer);
                  
                  Get.snackbar(
                    '로그인 성공',
                    '${customer.cName}님 환영합니다!',
                    snackPosition: SnackPosition.BOTTOM,
                  );

                  // TODO: 임시 - cheng 폴더의 search_view 사용 (나중에 원래대로 되돌릴 예정)
                  Get.offAll(() => const cheng_search.SearchView());
                  // 원래 코드 (되돌릴 때 사용):
                  // Get.offAll(() => const SearchView());
                } else if (statusKey == 1) {
                  // 휴면 회원 (status 1) - 로그인 차단
                  print('[WARNING] ========== 휴면 회원 처리 ==========');
                  print('[WARNING] Customer ID: ${customer.id}');
                  print('[WARNING] 원본 Status: "$currentStatus"');
                  print('[WARNING] StatusKey: $statusKey');
                  print('[WARNING] StatusValue: "$statusValue"');
                  print('[WARNING] 휴면 회원 로그인 시도 - 로그인 차단');
                  print('[WARNING] ====================================');
                  CustomDialog.show(
                    context,
                    title: '로그인 불가',
                    message: '휴면 회원입니다.',
                    type: DialogType.single,
                    confirmText: '확인',
                  );
                  return; // 로그인 차단
                } else if (statusKey == 2) {
                  // 탈퇴 회원 (status 2) - 로그인 차단
                  print('[WARNING] ========== 탈퇴 회원 처리 ==========');
                  print('[WARNING] Customer ID: ${customer.id}');
                  print('[WARNING] 원본 Status: "$currentStatus"');
                  print('[WARNING] StatusKey: $statusKey');
                  print('[WARNING] StatusValue: "$statusValue"');
                  print('[WARNING] 탈퇴 회원 로그인 시도 - 로그인 차단');
                  print('[WARNING] ====================================');
                  CustomDialog.show(
                    context,
                    title: '로그인 불가',
                    message: '탈퇴 회원입니다.',
                    type: DialogType.single,
                    confirmText: '확인',
                  );
                  return; // 로그인 차단
                } else if (statusKey == null) {
                  // statusKey가 null인 경우 - currentStatus를 직접 확인
                  print('[WARNING] ========== StatusKey가 null 처리 ==========');
                  print('[WARNING] Customer ID: ${customer.id}');
                  print('[WARNING] 원본 Status: "$currentStatus"');
                  print('[WARNING] StatusKey: $statusKey (null)');
                  print('[WARNING] 원본 Status로 직접 확인 시도');
                  
                  // 직접 문자열 비교로 탈퇴 회원 확인
                  print('[WARNING] 직접 비교: currentStatus == "탈퇴 회원": ${currentStatus == '탈퇴 회원'}');
                  print('[WARNING] 직접 비교: currentStatus == "2": ${currentStatus == '2'}');
                  print('[WARNING] 직접 비교: currentStatus.contains("탈퇴"): ${currentStatus.contains('탈퇴')}');
                  
                  if (currentStatus == '탈퇴 회원' || currentStatus == '2' || currentStatus.contains('탈퇴')) {
                    print('[WARNING] ✓ 탈퇴 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}');
                    print('[WARNING] 로그인 차단');
                    CustomDialog.show(
                      context,
                      title: '로그인 불가',
                      message: '탈퇴 회원입니다.',
                      type: DialogType.single,
                      confirmText: '확인',
                    );
                    return; // 로그인 차단
                  } else if (currentStatus == '휴면 회원' || currentStatus == '1' || currentStatus.contains('휴면')) {
                    print('[WARNING] ✓ 휴면 회원으로 판단 (직접 비교) - Customer ID: ${customer.id}');
                    print('[WARNING] 로그인 차단');
                    CustomDialog.show(
                      context,
                      title: '로그인 불가',
                      message: '휴면 회원입니다.',
                      type: DialogType.single,
                      confirmText: '확인',
                    );
                    return; // 로그인 차단
                  }
                  print('[WARNING] ===========================================');
                  
                  // 알 수 없는 상태
                  print('[ERROR] 알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: $currentStatus, StatusKey: $statusKey');
                  print('[DEBUG] 예상되는 상태 키: 0, 1, 2');
                  print('[DEBUG] 예상되는 상태 값: ${config.loginStatus[0]}, ${config.loginStatus[1]}, ${config.loginStatus[2]}');
                  Get.snackbar(
                    '오류',
                    '로그인 상태를 확인할 수 없습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                  );
                  return;
                } else {
                  // 알 수 없는 상태 (statusKey가 0, 1, 2가 아닌 경우)
                  print('[ERROR] 알 수 없는 로그인 상태 - Customer ID: ${customer.id}, Status: $currentStatus, StatusKey: $statusKey');
                  print('[DEBUG] 예상되는 상태 키: 0, 1, 2');
                  print('[DEBUG] 예상되는 상태 값: ${config.loginStatus[0]}, ${config.loginStatus[1]}, ${config.loginStatus[2]}');
                  Get.snackbar(
                    '오류',
                    '로그인 상태를 확인할 수 없습니다.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900,
                  );
                  return;
                }
              } else {
                // 로그인 히스토리가 없으면 신규 생성
                print('[DEBUG] 로그인 히스토리가 없음 - 신규 생성 시도');
                await _createLoginHistory(customer, loginHistoryDAO);
                
                // 사용자 정보를 get_storage에 저장
                UserStorage.saveUser(customer);
                
                Get.snackbar(
                  '로그인 성공',
                  '${customer.cName}님 환영합니다!',
                  snackPosition: SnackPosition.BOTTOM,
                );

                // TODO: 임시 - cheng 폴더의 search_view 사용 (나중에 원래대로 되돌릴 예정)
                Get.offAll(() => const cheng_search.SearchView());
                // 원래 코드 (되돌릴 때 사용):
                // Get.offAll(() => const SearchView());
              }
            } catch (e, stackTrace) {
              // EMPTY 예외는 로그인 히스토리가 없다는 의미이므로 정상적인 경우
              if (e.toString().contains('EMPTY')) {
                print('[INFO] 로그인 히스토리가 없음 (정상) - Customer ID: ${customer.id}');
                print('[DEBUG] 로그인 히스토리 신규 생성 시도');
                await _createLoginHistory(customer, loginHistoryDAO);
              } else {
                // 예상치 못한 예외인 경우에만 ERROR로 처리
                print('[ERROR] 로그인 히스토리 조회 중 예상치 못한 에러 발생 - Customer ID: ${customer.id}');
                print('[ERROR] 에러 메시지: $e');
                print('[ERROR] 스택 트레이스: $stackTrace');
                print('[WARNING] 예상치 못한 예외 발생 - 로그인 히스토리 생성 시도');
                await _createLoginHistory(customer, loginHistoryDAO);
              }
              
              // 사용자 정보를 get_storage에 저장
              UserStorage.saveUser(customer);
              
              Get.snackbar(
                '로그인 성공',
                '${customer.cName}님 환영합니다!',
                snackPosition: SnackPosition.BOTTOM,
              );

              // TODO: 임시 - cheng 폴더의 search_view 사용 (나중에 원래대로 되돌릴 예정)
              Get.offAll(() => const cheng_search.SearchView());
              // 원래 코드 (되돌릴 때 사용):
              // Get.offAll(() => const SearchView());
            }
          } else {
            // Customer ID가 없는 경우
            print('[ERROR] Customer ID가 null입니다 - 로그인 처리 불가');
            print('[DEBUG] Customer 정보: ${customer.toString()}');
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
          print('[DEBUG] 로그인 실패 - 입력값과 일치하는 고객 정보 없음');
          print('[DEBUG] 입력 ID/이메일/전화번호: $input');
          print('[DEBUG] 입력 형식: ${isEmail ? "이메일" : "전화번호"}');
          print('[DEBUG] 조회 쿼리 맵: $queryMap');
          Get.snackbar(
            '로그인 실패',
            '이메일/전화번호 또는 비밀번호가 올바르지 않습니다.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }).catchError((error, stackTrace) {
        // 에러 처리
        print('[ERROR] 로그인 처리 중 예외 발생');
        print('[ERROR] 에러 타입: ${error.runtimeType}');
        print('[ERROR] 에러 메시지: $error');
        print('[ERROR] 스택 트레이스: $stackTrace');
        print('[DEBUG] 입력 ID/이메일/전화번호: $input');
        print('[DEBUG] 입력 형식: ${isEmail ? "이메일" : "전화번호"}');
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

  /// 로그인 히스토리 생성 (중복 코드 제거)
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
      print('[DEBUG] 로그인 히스토리 생성 성공 - Customer ID: ${customer.id}, LoginTime: $currentTime');
    } catch (e, stackTrace) {
      // 로그인 히스토리 생성 실패는 로그인 성공에 영향을 주지 않음
      print('[ERROR] 로그인 히스토리 생성 실패 - Customer ID: ${customer.id}');
      print('[ERROR] 에러 메시지: $e');
      print('[ERROR] 스택 트레이스: $stackTrace');
      print('[DEBUG] 생성 시도한 LoginHistory 데이터: ${newLoginHistory.toMap()}');
      // 에러는 무시하고 계속 진행
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
