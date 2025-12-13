// Flutter imports
import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:flutter/material.dart';
import 'package:bookstore_app/config.dart' as config;
// Third-party package imports
import 'package:get/get.dart';

// Local imports - Storage
import '../../storage/user_storage.dart';

// Local imports - Screens
import '../../test_navigation_page.dart';
import 'user_profile_edit_view.dart';
import 'order_list_view.dart';
import 'return_list_view.dart';
import '../../../customer/address_payment_view.dart';
import '../auth/login_view.dart';

//  SearchView page
/*
  Create: 12/12/2025 11:44, Creator: Chansol, Park
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    13/12/2025 16:47, 'Point 1, Clicking card Get.toNamed -> DetailView', Creator: Chansol Park
    13/12/2025 17:18, 'Point 2, Card will show ProductBase instead of Product, Assembly based on pbid', Creator: Chansol Park
  Version: 1.0
  Desc: SearchView page

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

// class ProductInstance {
//   final String name;
//   final String manufacturer;
//   final int price;
//   final String imageUrl;
//   final int pbid;
//   final int mfid;

//   ProductInstance({
//     required this.name,
//     required this.manufacturer,
//     required this.price,
//     required this.imageUrl,
//     required this.pbid,
//     required this.mfid
//   });
// }

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  //  DBHandlers
  final manufacturerDAO = RDAO<Manufacturer>(
    dbName: dbName,
    tableName: config.kTableManufacturer,
    dVersion: dVersion,
    fromMap: Manufacturer.fromMap,
  );
  final productDAO = RDAO<Product>(
    dbName: dbName,
    tableName: config.kTableProduct,
    dVersion: dVersion,
    fromMap: Product.fromMap,
  );

  final productBaseDAO = RDAO<ProductBase>(
    dbName: dbName,
    tableName: config.kTableProductBase,
    dVersion: dVersion,
    fromMap: ProductBase.fromMap,
  );

  final productImageDAO = RDAO<ProductImage>(
    dbName: dbName,
    tableName: config.kTableProductImage,
    dVersion: dVersion,
    fromMap: ProductImage.fromMap,
  );
  // 사용자 정보를 저장할 변수
  String _userName = '사용자';
  String _userEmail = '이메일 없음';

  // Dummy
  // final List<Product> _allProducts = [
  //   Product(
  //     name: 'Nikke',
  //     manufacturer: 'Resti NB',
  //     price: 129000,
  //     imageUrl:
  //         'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
  //   ),
  //   Product(
  //     name: 'Hebi.',
  //     manufacturer: 'Resti Nike',
  //     price: 159000,
  //     imageUrl:
  //         'https://images.pexels.com/photos/1032110/pexels-photo-1032110.jpeg',
  //   ),
  //   Product(
  //     name: 'Restitutor',
  //     manufacturer: 'Shoe King',
  //     price: 199000,
  //     imageUrl:
  //         'https://images.pexels.com/photos/2529147/pexels-photo-2529147.jpeg',
  //   ),
  // ];

  // late List<Product> _filteredProducts;
  final TextEditingController _searchController = TextEditingController();
  List<ProductBase>? _allPBs; //  Entire PB
  List<ProductBase>? _filteredPBs; //  Searched PB

  Map<int, Product> _prodMap = {}; // pbid -> Product
  Map<int, Manufacturer> _mfMap = {}; // mfid -> Manufacturer

  Map<int, ProductImage> _imgMap = {}; // pbid -> ProductImage
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // _filteredProducts = List.from(_allProducts);
    // 사용자 정보 로드
    _loadUserInfo();
    loadProductData();
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

  Future<void> loadProductData() async {
    setState(() => _loading = true);

    // 1) ProductBase 전부
    final pbs = await productBaseDAO.queryAll();

    // 2) pbid 목록 수집
    final pbids = <int>{};
    for (final pb in pbs) {
      if (pb.id != null) pbids.add(pb.id!);
    }

    // 3) pbid -> Product(대표 1개) 캐싱 + mfid 수집
    final prodMap = <int, Product>{};
    final mfids = <int>{};

    for (final pbid in pbids) {
      try {
        final list = await productDAO.queryK({'pbid': pbid});
        final prod = list.first;
        prodMap[pbid] = prod;

        // Product에 mfid가 있다고 가정 (네 구조상 여기 있어야 함)
        if (prod.mfid != null) {
          mfids.add(prod.mfid!);
        }
      } catch (_) {
        // Product가 없으면 그냥 스킵
      }
    }

    // 4) mfid -> Manufacturer 캐싱
    final mfMap = <int, Manufacturer>{};
    for (final mfid in mfids) {
      try {
        final list = await manufacturerDAO.queryK({'id': mfid});
        mfMap[mfid] = list.first;
      } catch (_) {
        // Manufacturer가 없으면 스킵
      }
    }

    // 5) pbid -> ProductImage(대표 1장) 캐싱
    final imgMap = <int, ProductImage>{};
    for (final pbid in pbids) {
      try {
        final list = await productImageDAO.queryK({'pbid': pbid});
        imgMap[pbid] = list.first;
      } catch (_) {
        // 이미지 없으면 스킵
      }
    }

    // 6) 상태 반영
    setState(() {
      _allPBs = pbs;
      _filteredPBs = pbs;

      _prodMap = prodMap;
      _mfMap = mfMap;
      _imgMap = imgMap;

      _loading = false;
    });
  }

  void _onSearchChanged(String keyword) {
    if (keyword.trim().isEmpty) {
      _filteredPBs = _allPBs;
    } else {
      final lower = keyword.toLowerCase();
      _filteredPBs = _allPBs!.where((p) {
        return p.pName.toLowerCase().contains(lower);
      }).toList();
    }
    setState(() {});
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
              _loadUserInfo();
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
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
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _filteredPBs!.length,
                    itemBuilder: (context, index) {
                      final pb = _filteredPBs![index];
                      final pbid = pb.id;

                      final prod = (pbid != null) ? _prodMap[pbid] : null;
                      final mf = (prod?.mfid != null)
                          ? _mfMap[prod!.mfid!]
                          : null;
                      final img = (pbid != null) ? _imgMap[pbid] : null;

                      final priceText = (prod?.basePrice ?? 0)
                          .toString(); // ✅ Product.basePrice

                      return GestureDetector(
                        onTap: () {
                          if (pbid == null) return;
                          Get.toNamed('/detailview', arguments: pbid);
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImage(img), // ✅ pb 필요 없음
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pb.pName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  mf?.mName ?? '제조사 없음',
                                  style: const TextStyle(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$priceText원',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ProductImage? img) {
    final path = img?.imagePath;
    if (path != null && path.isNotEmpty) {
      return Image.asset(path, fit: BoxFit.cover, width: double.infinity);
    }
    return Image.asset(
      'assets/images/no_image.png',
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  Drawer _buildUserDrawer() {
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
            currentAccountPicture: CircleAvatar(child: Text(userInitial)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('프로필'),
            onTap: () async {
              Navigator.of(context).pop(); // 드로워 닫기
              // 개인정보 수정 페이지로 이동하고 결과를 받아서 사용자 정보 갱신
              final result = await Get.to(() => const UserProfileEditView());
              // 개인정보 수정이 완료되면 사용자 정보를 다시 로드하여 drawer 갱신
              if (result == true) {
                _loadUserInfo();
                setState(() {
                  // drawer가 다시 빌드되도록 setState 호출
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('주문 내역'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const OrderListView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment_return),
            title: const Text('수령 / 반품 내역'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const ReturnListView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
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
                        Get.offAll(() => const LoginView());
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('테스트 페이지로 이동'),
            onTap: () {
              Navigator.of(context).pop(); // 드로워 닫기
              Get.to(() => const TestNavigationPage());
            },
          ),
        ],
      ),
    );
  }
}

/*
// 테스트 페이지로 이동 버튼 (임시)
                      CustomButton(
                        btnText: '테스트 페이지로 이동',
                        buttonType: ButtonType.outlined,
                        onCallBack: _navigateToTestPage,
                        minimumSize: const Size(double.infinity, 56),
                      ),
*/
