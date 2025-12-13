import 'package:bookstore_app/config.dart';
import 'package:bookstore_app/config.dart' as config;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

//  Cart page
/*
  Create: 12/12/2025 10:46, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    13/12/2025 19:14, 'Point 1, Atcual data attached', Creator: Chansol Park
  Version: 1.0
  Dependency: SQFlite, Path, collection
  Desc: Cart page MUST have lists of Products

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:bookstore_app/config.dart' as config;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final box = GetStorage();

  List<Map<String, dynamic>> cart = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    final dynamic raw = box.read('cart');
    final List list = (raw is List) ? raw : [];

    cart = list.map<Map<String, dynamic>>((e) {
      // GetStorage에서 dynamic으로 오기 때문에 안전 변환
      if (e is Map<String, dynamic>) return e;
      return Map<String, dynamic>.from(e as Map);
    }).toList();

    setState(() => loading = false);
  }

  Future<void> _saveCart() async {
    await box.write('cart', cart);
    setState(() {}); // UI 갱신
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

  Future<void> _inc(int index) async {
    cart[index]['quantity'] = _asInt(cart[index]['quantity'], 1) + 1;
    await _saveCart();
  }

  Future<void> _dec(int index) async {
    final q = _asInt(cart[index]['quantity'], 1);
    if (q <= 1) return;
    cart[index]['quantity'] = q - 1;
    await _saveCart();
  }

  Future<void> _remove(int index) async {
    cart.removeAt(index);
    await _saveCart();
  }

  void _goPurchase() {
    if (cart.isEmpty) {
      Get.snackbar('장바구니', '비어있음', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // 결제 화면으로 이동 + cart 전체 넘김
    Get.toNamed('/purchase', arguments: cart);
  }

  Future<void> _clearCart() async {
    cart.clear();
    await box.remove('cart');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart', style: config.rLabel),
        actions: [
          IconButton(
            onPressed: cart.isEmpty ? null : _clearCart,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: '전체 삭제',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: cart.isEmpty
                      ? Center(child: Text('장바구니가 비어있음', style: config.rLabel))
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];

                            final img = (item['imagePath'] as String?)?.trim();
                            final name = (item['name'] as String?) ?? 'NO NAME';
                            final color = (item['color'] as String?) ?? '';
                            final size = _asInt(item['size'], 0);
                            final unitPrice = _asInt(item['unitPrice'], 0);
                            final qty = _asInt(item['quantity'], 1);
                            final lineTotal = unitPrice * qty;

                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 이미지: 없는 경로면 기본 이미지
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: (img != null && img.isNotEmpty)
                                          ? Image.asset(
                                              img,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) =>
                                                  Image.asset('assets/images/no_image.png', fit: BoxFit.contain),
                                            )
                                          : Image.asset('assets/images/no_image.png', fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: config.rLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text('색상: $color / 사이즈: $size', style: config.rLabel),
                                          const SizedBox(height: 6),
                                          Text('단가: ${config.priceFormatter.format(unitPrice)}원', style: config.rLabel),
                                          const SizedBox(height: 4),
                                          Text('합계: ${config.priceFormatter.format(lineTotal)}원', style: config.rLabel),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () => _dec(index),
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text('$qty', style: config.rLabel),
                                            IconButton(
                                              onPressed: () => _inc(index),
                                              icon: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () => _remove(index),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // 총액 + 결제 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '총액: ${config.priceFormatter.format(totalPrice)}원',
                          style: config.rLabel,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: cart.isEmpty ? null : _goPurchase,
                        child: Text('결제 화면', style: config.rLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

