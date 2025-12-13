import 'package:bookstore_app/config.dart' as config;
import 'package:bookstore_app/model/sale/purchase_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//  PurchaseView page
/*
  Create: 12/12/2025 16:24, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: PurchaseView page MUST have arguments from cart.dart

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  //  Property
  late List<PurchaseItem>? purchaseList;

  @override
  void initState() {
    super.initState();
    purchaseList = Get.arguments; //  MUST given by cart.dart
    //  Dummy
    purchaseList = List.filled(
      1,
      PurchaseItem(pid: 1, pcid: 1, pcQuantity: 30, pcStatus: '결제 대기'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (purchaseList == null) {
      return Scaffold(
        appBar: AppBar(title: Text('오류', style: config.rLabel)),
        body: const Center(
          child: Text('구매 내역이 없거나 오류가 있습니다', style: config.rLabel),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.payment),
            Text('결제 하기', style: config.rLabel),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: purchaseList!.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 10,
                  child: Row(
                    children: [
                      Image.asset(
                        'images/Newbalance_U740WN2/Newbalnce_U740WN2_Black_01.png', //  MUST be fixed on actual release
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 20),
                      Text('THIS IS DUMMY'),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text(
                            '구매 수량: ${purchaseList![index].pcQuantity}',
                            style: config.rLabel,
                          ), //  MUST be fixed on actual release
                          SizedBox(height: 10),
                          Text(
                            '구매 가격: ${purchaseList![index].pid}',
                            style: config.rLabel,
                          ), //  MUST be fixed on actual release
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              _lastPurchasePoint();
            },
            child: Text("결제 하기", style: config.rLabel),
          ),
        ),
      ),
    );
  }

  //  Functions
  void _lastPurchasePoint() {
    // district (대리점이 자치구당 1개라는 조건 -> 배송지 대용)
    final districts = <String>["강남구", "서초구", "송파구", "강동구", "마포구", "용산구"];

    // GetX state
    final RxString district = districts.first.obs;
    final RxBool confirmed = false.obs;

    // 총액(더미 로직): pid * qty 합 (실제론 unitPrice * qty)
    final int totalPrice = (purchaseList ?? []).fold<int>(
      0,
      (sum, e) => sum + ((e.pid ?? 0) * (e.pcQuantity ?? 0)),
    );

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
              // handle
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
                  const Icon(Icons.flash_on),
                  const SizedBox(width: 8),
                  Text("즉시 구매", style: config.rLabel),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 배송지(district)
              Align(
                alignment: Alignment.centerLeft,
                child: Text("주소지(자치구)", style: config.rLabel),
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
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(d, style: config.rLabel),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) district.value = v;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 결제수단(더미)
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
                child: Text("Dummy Payment (카드)", style: config.rLabel),
              ),

              const SizedBox(height: 14),

              // 총액
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
                    Text("$totalPrice", style: config.rLabel),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 슬라이드(오른쪽 끝까지 밀면 확정)
              Obx(
                () => SlideToBuyBar(
                  enabled: !confirmed.value,
                  label: confirmed.value ? "구매 처리중..." : "오른쪽으로 밀어서 즉시 구매",
                  onConfirmed: () async {
                    confirmed.value = true;

                    // TODO: 구매 처리(더미)
                    await Future.delayed(const Duration(milliseconds: 600));

                    Get.back(); // sheet 닫기
                    Get.snackbar(
                      "구매 완료",
                      "배송지: ${district.value} / 결제: Dummy Payment / 총액: $totalPrice",
                      snackPosition: SnackPosition.BOTTOM,
                    );
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
  double _t = 0.0; // 0~1
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
              // 파란 진행 바
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

              // 라벨
              Center(child: Text(widget.label, style: config.rLabel)),

              // 손잡이
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
