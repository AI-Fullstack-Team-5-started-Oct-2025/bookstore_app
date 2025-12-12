import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/login_history.dart';
import 'package:bookstore_app/mv/oncrate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//  AddressPaymentView page
/*
  Create: 12/12/2025 15:48, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: AddressPaymentView page MUST have lists of PurchaseItem

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class AddressPaymentView extends StatefulWidget {
  const AddressPaymentView({super.key});

  @override
  State<AddressPaymentView> createState() => _AddressPaymentViewState();
}

class _AddressPaymentViewState extends State<AddressPaymentView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressController = TextEditingController();
  late TextEditingController _paymentController = TextEditingController();

  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;

  late final RDAO<LoginHistory> _loginHistoryDAO;

  late int _loginHistory;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _paymentController = TextEditingController();
    _loginHistoryDAO = RDAO<LoginHistory>(
      dbName: dbName,
      tableName: config.kTableLoginHistory,
      dVersion: dVersion,
      fromMap: LoginHistory.fromMap,
    );
    _loginHistory = 0; //  Get.arguments?
  }

  @override
  void dispose() {
    _addressController.dispose();
    _paymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_userId == null) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('Loading...')),
    //     body: const Center(child: CircularProgressIndicator()),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text('주소 / 결제방법', style: config.rLabel),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('배송지', style: config.rLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  style: config.rLabel,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '예) 서울시 어딘가로 123, 101동 1001호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '배송지를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Payment method', style: config.rLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _paymentController,
                  style: config.rLabel,
                  decoration: InputDecoration(
                    hintText: '예) 신한카드 ****-****-****-1234',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '결제 방법을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _onSavePressed,
            child: Text('변경하기', style: config.rLabel),
          ),
        ),
      ),
    );
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    final String address = _addressController.text.trim();
    final String payment = _paymentController.text.trim();

    final inputData = {'lAddress': address, 'lPaymentMethod': payment};

    final result = await _loginHistoryDAO.insertK(inputData);
    setState(() {});
    if (result == -1) {
      Get.defaultDialog(
        title: '입력 실패',
        middleText: '입력에 실패하였습니다',
        barrierDismissible: false,
        textConfirm: '확인',
        confirmTextColor: Colors.white,
        onConfirm: () {
          _addressController.text = '';
          _paymentController.text = '';
          Get.back();
        },
      );
    }
    Get.defaultDialog(
        title: '입력 성공',
        middleText: '주소: $address\n 배송지: $payment',
        barrierDismissible: false,
        textConfirm: '확인',
        confirmTextColor: Colors.white,
        onConfirm: () {
          _addressController.text = '';
          _paymentController.text = '';
          Get.back();
          Get.back();
        },
      );
  }
}
