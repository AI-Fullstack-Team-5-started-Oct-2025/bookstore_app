import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Restitutor_custom/dao_custom.dart';
import '../../config.dart' as config;
import '../../model/customer.dart';
import 'custom/custom.dart';
import 'package:bookstore_app/db_setting.dart';
import 'customer_sub_dir/user_storage.dart';

/// 사용자 개인정보 수정 화면
/// 사용자가 자신의 개인정보를 수정할 수 있는 화면입니다.
/// 이메일은 아이디 역할을 하므로 수정할 수 없습니다.

class UserProfileEditScreen extends StatefulWidget {
  const UserProfileEditScreen({super.key});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  /// Form 검증을 위한 키
  final _formKey = GlobalKey<FormState>();

  /// 이름 입력 컨트롤러
  final TextEditingController _nameController = TextEditingController();

  /// 전화번호 입력 컨트롤러
  final TextEditingController _phoneController = TextEditingController();

  /// 비밀번호 입력 컨트롤러
  final TextEditingController _passwordController = TextEditingController();

  /// 비밀번호 확인 입력 컨트롤러
  final TextEditingController _passwordConfirmController = TextEditingController();

  /// 데이터베이스 설정 객체 (initState에서 초기화)
  late final DbSetting dbSetting;
  /// 고객 데이터 접근 객체 (initState에서 초기화)
  late final RDAO<Customer> customerDAO;

  /// 현재 사용자 정보 (get_storage에서 가져온 데이터)
  Customer? _currentCustomer;

  /// 이메일 (수정 불가, 읽기 전용)
  String _email = '';

  @override
  void initState() {
    super.initState();

    // 상태 관리 변수 초기화
    dbSetting = DbSetting();
    customerDAO = RDAO<Customer>(
      dbName: dbName,
      tableName: config.kTableCustomer,
      dVersion: dVersion,
      fromMap: Customer.fromMap,
    );

    // DB 초기화는 main.dart에서 이미 수행되므로 여기서는 호출하지 않습니다.

    // get_storage에서 사용자 정보 가져오기
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  /// get_storage에서 사용자 정보를 가져와서 폼에 채우는 함수
  void _loadUserData() {
    final customer = UserStorage.getUser();

    if (customer != null) {
      // DB에서 최신 정보 가져오기
      customerDAO.queryK({'cEmail': customer.cEmail}).then((customers) {
        if (customers.isNotEmpty) {
          final latestCustomer = customers.first;
          setState(() {
            _currentCustomer = latestCustomer;
            _email = latestCustomer.cEmail;
            _nameController.text = latestCustomer.cName;
            _phoneController.text = latestCustomer.cPhoneNumber;
            // 비밀번호는 저장하지 않으므로 비워둠
          });
        } else {
          // DB에 사용자가 없으면 이전 페이지로 돌아가기
          Get.back();
          Get.snackbar(
            '오류',
            '사용자 정보를 찾을 수 없습니다.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }).catchError((error) {
        print('사용자 정보 로드 에러: $error');
        Get.back();
        Get.snackbar(
          '오류',
          '사용자 정보를 불러오는 중 오류가 발생했습니다.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      });
    } else {
      // 저장된 정보가 없으면 이전 페이지로 돌아가기
      Get.back();
      Get.snackbar(
        '오류',
        '로그인 정보를 찾을 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 키보드 내리기
      onTap: _unfocusKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: CustomAppBar(
          title: '개인정보 수정',
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: CustomPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: CustomColumn(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 24,
                      children: [
                        // 개인정보 수정 타이틀
                        CustomText(
                          '개인정보 수정',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),

                        // 이메일 입력 필드 (읽기 전용, 수정 불가)
                        CustomTextField(
                          controller: TextEditingController(text: _email),
                          labelText: '이메일 (아이디)',
                          hintText: '이메일',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          enabled: false, // 수정 불가
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),

                        // 이름 입력 필드
                        CustomTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '이름을 입력하세요',
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.person),
                          required: true,
                          requiredMessage: '이름을 입력해주세요',
                        ),

                        // 전화번호 입력 필드
                        CustomTextField(
                          controller: _phoneController,
                          labelText: '전화번호',
                          hintText: '전화번호를 입력하세요',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone),
                          required: true,
                          requiredMessage: '전화번호를 입력해주세요',
                        ),

                        // 비밀번호 입력 필드
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          hintText: '새 비밀번호를 입력하세요 (변경하지 않으려면 비워두세요)',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock),
                        ),

                        // 비밀번호 확인 입력 필드
                        CustomTextField(
                          controller: _passwordConfirmController,
                          labelText: '비밀번호 확인',
                          hintText: '비밀번호를 다시 입력하세요 (변경하지 않으려면 비워두세요)',
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),

                        // 수정하기 버튼
                        CustomButton(
                          btnText: '수정하기',
                          buttonType: ButtonType.elevated,
                          onCallBack: _handleUpdate,
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

  /// 수정하기 버튼 클릭 처리 함수
  /// 다이얼로그로 확인 후 DB와 get_storage를 업데이트합니다.
  void _handleUpdate() {
    // 키보드 내리기
    _unfocusKeyboard();

    // Form 검증
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 이름과 전화번호 필수 검증
    if (!CustomTextField.textCheck(context, _nameController)) {
      CustomSnackBar.showError(context, message: '이름을 입력해주세요');
      return;
    }

    if (!CustomTextField.textCheck(context, _phoneController)) {
      CustomSnackBar.showError(context, message: '전화번호를 입력해주세요');
      return;
    }

    // 비밀번호 입력 여부 확인 및 일치 확인
    final password = _passwordController.text.trim();
    final passwordConfirm = _passwordConfirmController.text.trim();

    // 비밀번호를 입력한 경우에만 비밀번호 확인 검증
    if (password.isNotEmpty) {
      // 비밀번호가 입력되었으면 비밀번호 확인도 입력되어야 함
      if (passwordConfirm.isEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호 확인을 입력해주세요');
        return;
      }
      // 비밀번호와 비밀번호 확인이 일치하는지 확인
      if (password != passwordConfirm) {
        CustomSnackBar.showError(context, message: '비밀번호가 일치하지 않습니다');
        return;
      }
    } else {
      // 비밀번호를 입력하지 않은 경우, 비밀번호 확인 필드도 비어있어야 함
      if (passwordConfirm.isNotEmpty) {
        CustomSnackBar.showError(context, message: '비밀번호를 입력하지 않으려면 비밀번호 확인도 비워두세요');
        return;
      }
    }

    // 원래 Scaffold의 context 저장 (다이얼로그 닫은 후 사용)
    final scaffoldContext = context;

    // 다이얼로그로 확인
    CustomDialog.show(
      context,
      title: '개인정보 수정 확인',
      message: '정말 수정하시겠습니까?',
      type: DialogType.dual,
      confirmText: '확인',
      cancelText: '취소',
      borderRadius: 12,
      autoDismissOnConfirm: false, // 수동으로 다이얼로그 닫기
      onConfirm: () async {
        print('다이얼로그 확인 버튼 클릭됨');
        // 확인 버튼 클릭 시 실제 업데이트 수행
        try {
          final success = await _performUpdate();
          print('업데이트 결과: $success');
          if (success) {
            // 성공 시 다이얼로그 닫기
            if (context.mounted) {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            }
            // 다이얼로그가 닫힌 후 원래 페이지로 이동 (성공 결과 반환)
            Future.delayed(const Duration(milliseconds: 100), () {
              if (scaffoldContext.mounted) {
                Navigator.of(scaffoldContext).pop(true); // 이전 페이지로 이동하고 성공 결과 반환
              }
            });
          } else {
            // 실패 시 다이얼로그만 닫기 (현재 페이지 유지)
            if (context.mounted) {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            }
          }
        } catch (e, stackTrace) {
          print('업데이트 중 예외 발생: $e');
          print('스택 트레이스: $stackTrace');
          // 에러 발생 시 다이얼로그 닫기
          if (context.mounted) {
            Navigator.of(context).pop(); // 다이얼로그 닫기
          }
          CustomSnackBar.showError(scaffoldContext, message: '업데이트 중 오류가 발생했습니다: $e');
        }
      },
      onCancel: () {
        // 취소 버튼 클릭 시 다이얼로그만 닫기 (저장하지 않음)
      },
    );
  }

  /// 실제 업데이트를 수행하는 함수
  /// DB와 get_storage를 업데이트합니다.
  /// 반환값: 성공 시 true, 실패 시 false
  Future<bool> _performUpdate() async {
    print('_performUpdate 시작');
    
    if (_currentCustomer == null) {
      print('사용자 정보가 null입니다');
      CustomSnackBar.showError(context, message: '사용자 정보를 찾을 수 없습니다');
      return false;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    print('업데이트할 데이터 - 이름: $name, 전화번호: $phone, 비밀번호 변경: ${password.isNotEmpty}');

    // 업데이트할 데이터 준비
    final updateData = <String, Object?>{
      'cName': name,
      'cPhoneNumber': phone,
    };

    // 비밀번호가 입력되었으면 비밀번호도 업데이트
    if (password.isNotEmpty) {
      updateData['cPassword'] = password;
    }

    try {
      print('DB 업데이트 시작 - 이메일: $_email');
      // DB 업데이트 (이메일을 키로 사용)
      final updateResult = await customerDAO.updateK(
        updateData,
        {'cEmail': _email},
      );
      print('DB 업데이트 결과: $updateResult');

      // get_storage 업데이트
      final updatedCustomer = Customer(
        id: _currentCustomer!.id,
        cEmail: _email,
        cPhoneNumber: phone,
        cName: name,
        cPassword: password.isNotEmpty ? password : _currentCustomer!.cPassword,
      );
      UserStorage.saveUser(updatedCustomer);
      print('get_storage 업데이트 완료');

      // 성공 메시지 표시
      Get.snackbar(
        '수정 완료',
        '개인정보가 수정되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );

      // 성공 반환
      print('_performUpdate 성공');
      return true;
    } catch (e, stackTrace) {
      // 에러 처리
      print('개인정보 수정 에러: $e');
      print('스택 트레이스: $stackTrace');
      CustomSnackBar.showError(context, message: '개인정보 수정 중 오류가 발생했습니다: $e');
      // 실패 반환
      return false;
    }
  }

  //----Function End----
}

