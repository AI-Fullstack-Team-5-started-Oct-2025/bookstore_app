import 'package:flutter/material.dart';
import 'custom/custom.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'admin_mobile_block_screen.dart';
import 'administer_employee_order_view.dart';
import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/model/customer.dart';
import 'package:bookstore_app/model/employee.dart';
import 'package:bookstore_app/config.dart' as config;

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
                const SizedBox(height: 32),
                CustomText(
                  'DB 스키마 검증 테스트',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  btnText: 'Customer 테이블 검증',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _testCustomerTable(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
                CustomButton(
                  btnText: 'Employee 테이블 검증',
                  buttonType: ButtonType.elevated,
                  onCallBack: () => _testEmployeeTable(context),
                  minimumSize: const Size(double.infinity, 56),
                ),
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

  // 주문 관리 화면으로 이동
  void _navigateToOrderView(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdministerEmployeeOrderView(),
      ),
    );
  }

  // Customer 테이블 검증
  Future<void> _testCustomerTable(BuildContext context) async {
    try {
      final rdb = RDB();
      final db = await RDB.instance(dbName, dVersion);
      await rdb.validateTableColumns(
        db: db,
        tableName: config.kTableCustomer,
        expectedColumns: Customer.keys,
      );
      if (context.mounted) {
        CustomSnackBar.showSuccess(context, message: 'Customer 테이블 스키마 검증 성공!');
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('Actual:   []')
            ? 'Customer 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
            : 'Customer 테이블 검증 실패: $e';
        CustomSnackBar.showError(context, message: errorMessage);
      }
    }
  }

  // Employee 테이블 검증
  Future<void> _testEmployeeTable(BuildContext context) async {
    try {
      final rdb = RDB();
      final db = await RDB.instance(dbName, dVersion);
      await rdb.validateTableColumns(
        db: db,
        tableName: config.tTableEmployee,
        expectedColumns: Employee.keys,
      );
      if (context.mounted) {
        CustomSnackBar.showSuccess(context, message: 'Employee 테이블 스키마 검증 성공!');
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString().contains('Actual:   []')
            ? 'Employee 테이블이 존재하지 않습니다. 데이터베이스를 초기화해주세요.'
            : 'Employee 테이블 검증 실패: $e';
        CustomSnackBar.showError(context, message: errorMessage);
      }
    }
  }

  //----Function End----
}
