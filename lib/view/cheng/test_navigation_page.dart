import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom/custom.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'admin_mobile_block_screen.dart';
import 'admin_login.dart';
import 'admin_employee_order_view.dart';
import 'admin_employee_return_order_view.dart';
import 'user_profile_edit.dart';
import '../../Restitutor_custom/dao_custom.dart';
import '../../model/customer.dart';
import '../../config.dart' as config;

// 네비게이션 테스트 페이지

class TestNavigationPage extends StatelessWidget {
  const TestNavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '네비게이션 테스트', centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  btnText: '회원가입 화면 (더미 데이터)',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToSignUpWithTestData(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: '사용자 프로필 수정 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToUserProfileEdit(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: '관리자 로그인 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToAdminLogin(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: '관리자 모바일 차단 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToAdminBlock(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: '주문 관리 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToOrderView(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: '반품 관리 화면',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _navigateToReturnOrderView(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                const SizedBox(height: 32),
                CustomText(
                  'DB 테스트',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                    CustomButton(
                      btnText: '모든 사용자 출력',
                      buttonType: ButtonType.elevated,
                      onCallBack: () => _printRecentCustomers(context),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                // const SizedBox(height: 32),
                // CustomText(
                //   'DB 스키마 검증 테스트',
                //   fontSize: 24,
                //   fontWeight: FontWeight.bold,
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 16),
                // CustomButton(
                //   btnText: 'Customer 테이블 검증',
                //   buttonType: ButtonType.elevated,
                //   onCallBack: () => _testCustomerTable(context),
                //   minimumSize: const Size(double.infinity, 56),
                // ),
                // CustomButton(
                //   btnText: 'Employee 테이블 검증',
                //   buttonType: ButtonType.elevated,
                //   onCallBack: () => _testEmployeeTable(context),
                //   minimumSize: const Size(double.infinity, 56),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----Function Start----

  // 로그인 화면으로 이동
  void _navigateToLogin(BuildContext context) {
    Get.to(() => const LoginScreen());
  }

  /// 회원가입 화면으로 이동
  void _navigateToSignUp(BuildContext context) {
    Get.to(() => const SignUpScreen());
  }

  /// 회원가입 화면으로 이동 (더미 데이터 포함)
  /// 인서트 로직 검증을 위한 테스트용 더미 데이터를 전달합니다.
  /// 
  /// 더미 데이터는 고정된 값으로 설정되어 있어 테스트 시 쉽게 찾을 수 있습니다.
  /// 중복 오류가 발생하면 DB에서 해당 데이터를 삭제한 후 다시 테스트하세요.
  void _navigateToSignUpWithTestData(BuildContext context) {
    // 테스트용 고정 더미 데이터 생성
    // Customer 모델의 필드에 맞춰 더미 데이터를 생성합니다.
    // 고정된 값으로 설정하여 테스트 시 쉽게 찾을 수 있도록 합니다.
    final testData = {
      'email': 'dummytest@example.com', // 테스트용 이메일 (고정값)
      'password': 'qwer1234', // 테스트용 비밀번호 (고정값: qwer1234)
      'name': '더미 테스트 사용자', // 테스트용 이름 (고정값)
      'phone': '010-9999-8888', // 테스트용 전화번호 (고정값)
      'autoAgree': 'true', // 약관 자동 동의 (테스트 편의)
    };

    // 더미 데이터와 함께 회원가입 화면으로 이동
    Get.to(() => SignUpScreen(testData: testData));
  }

  /// 사용자 프로필 수정 화면으로 이동
  void _navigateToUserProfileEdit(BuildContext context) {
    Get.to(() => const UserProfileEditScreen());
  }

  // 관리자 로그인 화면으로 이동
  void _navigateToAdminLogin(BuildContext context) {
    Get.to(() => const AdminLoginScreen());
  }

  // 관리자 모바일 차단 화면으로 이동
  void _navigateToAdminBlock(BuildContext context) {
    Get.to(() => const AdminMobileBlockScreen());
  }

  // 주문 관리 화면으로 이동
  void _navigateToOrderView(BuildContext context) {
    Get.to(() => const AdministerEmployeeOrderView());
  }

  // 반품 관리 화면으로 이동
  void _navigateToReturnOrderView(BuildContext context) {
    Get.to(() => const AdministerEmployeeReturnOrderView());
  }

  /// 등록된 모든 사용자를 터미널에 출력하는 함수
  /// Customer DB에서 모든 사용자를 조회하고, ID 기준으로 정렬하여 모두 출력합니다.
  Future<void> _printRecentCustomers(BuildContext context) async {
    try {
      // Customer DAO 생성
      // 주의: svInitDB()를 호출하지 않습니다. 
      // svInitDB()는 DB를 초기화하고 더미 데이터를 다시 삽입하므로,
      // 조회만 할 때는 호출하면 안 됩니다.
      final customerDAO = RDAO<Customer>(
        dbName: dbName,
        tableName: config.kTableCustomer,
        dVersion: dVersion,
        fromMap: Customer.fromMap,
      );

      print('\n${'=' * 60}');
      print('DB 조회 시작...');
      print('=' * 60);

      // 모든 Customer 조회
      final allCustomers = await customerDAO.queryAll();

      print('조회된 사용자 수: ${allCustomers.length}');

      if (allCustomers.isEmpty) {
        print('=' * 60);
        print('등록된 사용자가 없습니다.');
        print('=' * 60);
        print('\n💡 팁: 회원가입 화면(더미 데이터) 버튼을 눌러 테스트 데이터를 추가하세요.');
        print('=' * 60 + '\n');
        Get.snackbar(
          '알림',
          '등록된 사용자가 없습니다.\n회원가입 화면(더미 데이터) 버튼을 눌러 테스트 데이터를 추가하세요.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // ID 기준으로 정렬 (내림차순: 최신순)
      allCustomers.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      // 모든 사용자 출력
      // 터미널에 출력
      print('\n${'=' * 60}');
      print('등록된 모든 사용자 (총 ${allCustomers.length}명)');
      print('=' * 60);
      
      for (int i = 0; i < allCustomers.length; i++) {
        final customer = allCustomers[i];
        print('\n[${i + 1}번째 사용자]');
        print('  ID: ${customer.id}');
        print('  이메일: ${customer.cEmail}');
        print('  전화번호: ${customer.cPhoneNumber}');
        print('  이름: ${customer.cName}');
        print('  비밀번호: ${customer.cPassword}');
        print('-' * 60);
      }
      
      print('\n총 ${allCustomers.length}명의 사용자가 등록되어 있습니다.');
      print('=' * 60 + '\n');

      // 사용자에게 알림 표시
      Get.snackbar(
        '출력 완료',
        '터미널에 등록된 모든 사용자 ${allCustomers.length}명을 출력했습니다.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      print('error: $e');
      print('stackTrace: $stackTrace');
      print('---------------');
      print('\n${'=' * 60}');
      print('에러 발생: $e');
      print('스택 트레이스:');
      print(stackTrace);
      print('=' * 60 + '\n');
      Get.snackbar(
        '에러',
        '사용자 정보를 가져오는 중 오류가 발생했습니다: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // Customer 테이블 검증
  // Future<void> _testCustomerTable(BuildContext context) async {
  //   try {
  //     final rdb = RDB();
  //     final db = await RDB.instance(dbName, dVersion);
  //     await rdb.validateTableColumns(
  //       db: db,
  //       tableName: config.kTableCustomer,
  //       expectedColumns: Customer.keys,
  //     );
  //     if (context.mounted) {
  //       CustomSnackBar.showSuccess(context, message: 'Customer 테이블 스키마 검증 성공!');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       final errorMessage = e.toString().contains('Actual:   []')
  //           ? 'Customer 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
  //           : 'Customer 테이블 검증 실패: $e';
  //       CustomSnackBar.showError(context, message: errorMessage);
  //     }
  //   }
  // }

  // Employee 테이블 검증
  // Future<void> _testEmployeeTable(BuildContext context) async {
  //   try {
  //     final rdb = RDB();
  //     final db = await RDB.instance(dbName, dVersion);
  //     await rdb.validateTableColumns(
  //       db: db,
  //       tableName: config.tTableEmployee,
  //       expectedColumns: Employee.keys,
  //     );
  //     if (context.mounted) {
  //       CustomSnackBar.showSuccess(context, message: 'Employee 테이블 스키마 검증 성공!');
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       final errorMessage = e.toString().contains('Actual:   []')
  //           ? 'Employee 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
  //           : 'Employee 테이블 검증 실패: $e';
  //       CustomSnackBar.showError(context, message: errorMessage);
  //     }
  //   }
  // }

  //----Function End----
}
