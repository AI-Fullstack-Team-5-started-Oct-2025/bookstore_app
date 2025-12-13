//  PurchaseView page
/*
  Create: 12/12/2025 16:24, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    13/12/2025 19:29, 'Point 1, Actual DB connected', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: PurchaseView page MUST have arguments from cart.dart

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bookstore_app/config.dart' as config;

// (선택) DB 저장까지 하려면 사용
import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/model/sale/purchase_item.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  final box = GetStorage();

  late final List<Map<String, dynamic>> cart;

  @override
  void initState() {
    super.initState();

    // ✅ CartView에서 넘긴 arguments(cart 리스트) 받기
    final raw = Get.arguments;
    final List list = (raw is List) ? raw : [];
    cart = list.map<Map<String, dynamic>>((e) {
      if (e is Map<String, dynamic>) return e;
      return Map<String, dynamic>.from(e as Map);
    }).toList();
  }

  int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  int get totalPrice {
    return cart.fold<int>(0, (sum, e) {
      final q = _asInt(e['quantity'], 1);
      final p = _asInt(e['unitPrice'], 0);
      return sum + (q * p);
    });
  }

  Future<void> _clearCart() async {
    await box.remove('cart');
  }

  // ✅ (선택) 결제 확정 시 PurchaseItem DB 저장
  // 테이블명은 네 config에 맞춰 수정 필요할 수 있어.
  Future<void> _savePurchaseItemsToDb() async {
    // TODO: pcid(고객id)는 실제 로그인 유저로 바꾸기
    const int pcid = 1;

    final String dbName = '${config.kDBName}${config.kDBFileExt}';
    final int dVersion = config.kVersion;

    final dao = RDAO<PurchaseItem>(
      dbName: dbName,
      tableName: config.kTablePurchaseItem, // 없으면 'purchase_item' 등으로 수정
      dVersion: dVersion,
      fromMap: PurchaseItem.fromMap,
    );

    for (final e in cart) {
      final item = PurchaseItem(
        pid: _asInt(e['productId']),
        pcid: pcid,
        pcQuantity: _asInt(e['quantity'], 1),
        pcStatus: '결제 완료',
      );

      await dao.insertK(item.toMap());
    }
  }

  void _openPaymentSheet() {
    final districts = <String>["강남구", "서초구", "송파구", "강동구", "마포구", "용산구"];
    final RxString district = districts.first.obs;
    final RxBool confirmed = false.obs;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(Icons.payment),
                  const SizedBox(width: 8),
                  Text("결제 확인", style: config.rLabel),
                  const Spacer(),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text("수령 지점(자치구)", style: config.rLabel),
              ),
              const SizedBox(height: 8),

              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    value: district.value,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: districts
                        .map((d) => DropdownMenuItem(value: d, child: Text(d, style: config.rLabel)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) district.value = v;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text("결제수단", style: config.rLabel),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text("카드(더미)", style: config.rLabel),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text("총액", style: config.rLabel)),
                    Text("${config.priceFormatter.format(totalPrice)}원", style: config.rLabel),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Obx(
                () => SlideToBuyBar(
                  enabled: !confirmed.value,
                  label: confirmed.value ? "결제 처리중..." : "오른쪽으로 밀어서 결제 확정",
                  onConfirmed: () async {
                    confirmed.value = true;

                    // ✅ 여기서 실제 결제/DB저장/정리
                    // 1) DB 저장(원하면)
                    try {
                      await _savePurchaseItemsToDb();
                    } catch (_) {
                      // DB 저장 실패해도 일단 UX는 진행(원하면 여기서 return 처리 가능)
                    }

                    // 2) cart 비우기
                    await _clearCart();

                    Get.back(); // sheet 닫기
                    Get.snackbar(
                      "구매 완료",
                      "수령지: ${district.value} / 총액: ${config.priceFormatter.format(totalPrice)}원",
                      snackPosition: SnackPosition.BOTTOM,
                    );

                    // 결제 후 이동(원하는 곳으로 바꾸면 됨)
                    Get.offAllNamed('/search'); // or Get.back() 등
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('결제', style: config.rLabel)),
        body: Center(child: Text('구매할 상품이 없습니다', style: config.rLabel)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('결제', style: config.rLabel),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final e = cart[index];
                final img = (e['imagePath'] as String?) ?? 'assets/images/no_image.png';
                final name = (e['name'] as String?) ?? 'NO NAME';
                final color = (e['color'] as String?) ?? '';
                final size = _asInt(e['size'], 0);
                final qty = _asInt(e['quantity'], 1);
                final unitPrice = _asInt(e['unitPrice'], 0);
                final lineTotal = unitPrice * qty;

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image.asset(
                          img,
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Image.asset('assets/images/no_image.png', width: 90, height: 90, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: config.rLabel),
                              const SizedBox(height: 4),
                              Text('색상: $color / 사이즈: $size', style: config.rLabel),
                              const SizedBox(height: 6),
                              Text('수량: $qty', style: config.rLabel),
                              Text('합계: ${config.priceFormatter.format(lineTotal)}원', style: config.rLabel),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: Text('총액: ${config.priceFormatter.format(totalPrice)}원', style: config.rLabel),
                ),
                ElevatedButton(
                  onPressed: _openPaymentSheet,
                  child: Text('결제하기', style: config.rLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SlideToBuyBar extends StatefulWidget {
  final bool enabled;
  final String label;
  final Future<void> Function() onConfirmed;

  const SlideToBuyBar({
    super.key,
    required this.enabled,
    required this.label,
    required this.onConfirmed,
  });

  @override
  State<SlideToBuyBar> createState() => _SlideToBuyBarState();
}

class _SlideToBuyBarState extends State<SlideToBuyBar> {
  double _t = 0.0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    const h = 56.0;
    const knob = 52.0;

    return LayoutBuilder(
      builder: (context, c) {
        final maxX = (c.maxWidth - knob).clamp(0, double.infinity);
        final x = maxX * _t;

        return Container(
          height: h,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _t.clamp(0.0, 1.0),
                    child: Container(color: Colors.blue.withOpacity(0.35)),
                  ),
                ),
              ),
              Center(child: Text(widget.label, style: config.rLabel)),
              Positioned(
                left: x,
                top: (h - knob) / 2,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    if (!widget.enabled || _done) return;
                    final next = ((_t * maxX) + d.delta.dx) / maxX;
                    setState(() => _t = next.clamp(0.0, 1.0));
                  },
                  onHorizontalDragEnd: (_) async {
                    if (!widget.enabled || _done) return;
                    if (_t > 0.92) {
                      setState(() {
                        _t = 1.0;
                        _done = true;
                      });
                      await widget.onConfirmed();
                    } else {
                      setState(() => _t = 0.0);
                    }
                  },
                  child: Container(
                    width: knob,
                    height: knob,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    child: Icon(
                      _done ? Icons.check : Icons.double_arrow_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
