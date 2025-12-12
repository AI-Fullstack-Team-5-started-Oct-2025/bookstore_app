import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Restitutor_custom/dao_custom.dart';
import '../../config.dart' as config;
import '../../model/employee.dart';
import 'custom/custom.dart';
import 'custom/custom_common_util.dart';
import 'package:bookstore_app/db_setting.dart';
import 'employee_sub_dir/admin_tablet_utils.dart';
import 'employee_sub_dir/admin_storage.dart';
import 'admin_employee_order_view.dart';
import 'admin_mobile_block_screen.dart';

/// 관리자 로그인 화면
/// 태블릿에서 가로 모드로 강제 표시되는 관리자 전용 로그인 화면입니다.
/// 관리자는 회원가입이 불가능하며 로그인만 가능합니다.

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>();

  /// 이메일 입력 컨트롤러
  final TextEditingController _emailController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 데이터베이스 설정 객체 (initState에서 초기화)
  late final DbSetting dbSetting;
  /// 직원 데이터 접근 객체 (initState에서 초기화)
  late final RDAO<Employee> employeeDAO;

  @override
  void initState() {
    super.initState();

    // 상태 관리 변수 초기화
    dbSetting = DbSetting();
    employeeDAO = RDAO<Employee>(
      dbName: dbName,
      tableName: config.tTableEmployee,
      dVersion: dVersion,
      fromMap: Employee.fromMap,
    );

    // DB 초기화는 main.dart에서 이미 수행되므로 여기서는 호출하지 않습니다.

    // 태블릿이 아니면 모바일 차단 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isTablet(context)) {
        Get.off(() => const AdminMobileBlockScreen());
      } else {
        // 태블릿이면 가로 모드로 고정
        lockTabletLandscape(context);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // 페이지 나갈 때 모든 방향 허용으로 복구
    unlockAllOrientations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 내리기
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '관리자 로그인',
          centerTitle: true,
          toolbarHeight: 48,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 24,
                      children: [
                        // 관리자 로그인 타이틀
                        CustomText(
                          '관리자 로그인',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),

                        // 안내 메시지
                        CustomText(
                          '태블릿에서만 접근 가능합니다',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          textAlign: TextAlign.center,
                          color: Colors.grey[600],
                        ),

                        // 이메일 또는 전화번호 입력 필드
                        CustomTextField(
                          controller: _emailController,
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

                        // 로그인 버튼
                        CustomButton(
                          btnText: '로그인',
                          buttonType: ButtonType.elevated,
                          onCallBack: _handleLogin,
                          minimumSize: const Size(double.infinity, 56),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //----Function Start----

  /// 키보드 내리기 함수
  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  /// 로그인 버튼 클릭 처리 함수
  /// 이메일 또는 전화번호와 비밀번호를 검증하고 직원 DB에서 조회하여 로그인을 처리합니다.
  void _handleLogin() {
    // 키보드 내리기
    _unfocusKeyboard();

    // Form 검증
    if (_formKey.currentState!.validate()) {
      final input = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 입력값이 이메일 형식인지 정교하게 확인
      final isEmail = CustomCommonUtil.isEmail(input);
      
      // 이메일이 아니면 전화번호로 간주하여 DB 조회
      // 전화번호 형식은 다양할 수 있으므로 (010-1234-5678, 222-6789-5432 등)
      // 이메일 형식이 아닌 모든 입력값을 전화번호로 처리
      final queryMap = isEmail
          ? {'eEmail': input, 'ePassword': password}
          : {'ePhoneNumber': input, 'ePassword': password};

      // 직원 DB에서 이메일 또는 전화번호와 비밀번호로 조회
      employeeDAO.queryK(queryMap).then((employees) {
        if (employees.isNotEmpty) {
          // 로그인 성공
          final employee = employees.first;
          print('관리자 로그인 성공: ${employee.eName}');
          
          // 관리자 정보를 get_storage에 저장
          AdminStorage.saveAdmin(employee);
          
          Get.snackbar(
            '로그인 성공',
            '${employee.eName}님 환영합니다!',
            snackPosition: SnackPosition.BOTTOM,
          );
          // 주문 관리 화면으로 이동
          Get.off(
            () => const AdministerEmployeeOrderView(),
            transition: Transition.fadeIn,
          );
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

  //----Function End----
}

