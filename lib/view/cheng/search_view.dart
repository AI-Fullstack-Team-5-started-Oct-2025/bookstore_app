import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'customer_sub_dir/user_storage.dart';
import 'user_profile_edit.dart';
import 'order_list_screen.dart';
import 'return_list_screen.dart';
import '../customer/address_payment_view.dart';
import 'login_screen.dart';

//  SearchView page
/*
  Create: 12/12/2025 11:44, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Desc: SearchView page

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Product {
  final String name;
  final String manufacturer;
  final int price;
  final String imageUrl;

  Product({
    required this.name,
    required this.manufacturer,
    required this.price,
    required this.imageUrl,
  });
}

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  // 사용자 정보를 저장할 변수
  String _userName = '사용자';
  String _userEmail = '이메일 없음';
  
  // Dummy
  final List<Product> _allProducts = [
    Product(
      name: 'Nikke',
      manufacturer: 'Resti NB',
      price: 129000,
      imageUrl:
          'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
    ),
    Product(
      name: 'Hebi.',
      manufacturer: 'Resti Nike',
      price: 159000,
      imageUrl:
          'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg',
    ),
    Product(
      name: 'Restitutor',
      manufacturer: 'Shoe King',
      price: 199000,
      imageUrl:
          'https://images.pexels.com/photos/2529147/pexels-photo-2529147.jpeg',
    ),
  ];

  late List<Product> _filteredProducts;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(_allProducts);
    
    // 사용자 정보 로드
    _loadUserInfo();
    
    // 디버깅: 저장된 사용자 정보 확인
    // get_storage가 비동기적으로 초기화될 수 있으므로 약간의 지연 후 확인
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _loadUserInfo();
      }
    });
  }

  /// 사용자 정보 로드
  void _loadUserInfo() {
    try {
      final savedUser = UserStorage.getUser();
      if (savedUser != null) {
        setState(() {
          _userName = savedUser.cName;
          _userEmail = savedUser.cEmail;
        });
        print('=== 사용자 정보 로드 성공 ===');
        print('  - 이름: $_userName');
        print('  - 이메일: $_userEmail');
      } else {
        // getUser()가 null이면 개별 메서드로 시도
        final name = UserStorage.getUserName();
        final email = UserStorage.getUserEmail();
        if (name != null || email != null) {
          setState(() {
            if (name != null) _userName = name;
            if (email != null) _userEmail = email;
          });
          print('=== 사용자 정보 로드 성공 (개별 메서드) ===');
          print('  - 이름: $_userName');
          print('  - 이메일: $_userEmail');
        } else {
          print('=== 사용자 정보 없음 ===');
        }
      }
    } catch (e) {
      print('사용자 정보 로드 에러: $e');
    }
  }

  void _onSearchChanged(String keyword) {
    setState(() {
      if (keyword.trim().isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        final lower = keyword.toLowerCase();
        _filteredProducts = _allProducts.where((p) {
          return p.name.toLowerCase().contains(lower) ||
              p.manufacturer.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),

      // 👤 Drawer 안에 사용자 정보
      drawer: _buildUserDrawer(),

      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // 🔥 Drawer 열기
            },
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Shoe King',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // 🔍 검색바 (페이지 안에서 검색)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '원하는 신발을 찾아보아요',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🥿 상품 카드 2열 그리드
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,      // 한 줄에 2개
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // 카드 세로 비율
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final p = _filteredProducts[index];
                return _ProductCard(product: p);
              },
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildUserDrawer() {
    // 저장된 사용자 정보 사용 (이미 _loadUserInfo()에서 로드됨)
    // 드로워가 열릴 때마다 최신 정보로 갱신
    _loadUserInfo();
    
    final userInitial = _userName.isNotEmpty && _userName != '사용자' 
        ? _userName[0].toUpperCase() 
        : 'U';
    
    // 디버깅: 드로워 빌드 시 사용자 정보 확인
    print('=== Drawer 빌드 - 사용자 정보 ===');
    print('  - userName: $_userName');
    print('  - userEmail: $_userEmail');
    print('  - getUserName(): ${UserStorage.getUserName()}');
    print('  - getUserEmail(): ${UserStorage.getUserEmail()}');

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName),
            accountEmail: Text(_userEmail),
            currentAccountPicture: CircleAvatar(
              child: Text(userInitial),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('프로필'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const UserProfileEditScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('주문 내역'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const OrderListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_return),
            title: const Text('수령 / 반품 내역'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const ReturnListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('배송지, 결제 방법 수정'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const AddressPaymentView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              // 로그아웃 확인 다이얼로그
              Get.dialog(
                AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        // 사용자 정보 삭제
                        UserStorage.clearUser();
                        // 로그인 화면으로 이동 (모든 페이지 제거)
                        Get.offAll(() => const LoginScreen());
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              product.manufacturer,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${product.price}원',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

