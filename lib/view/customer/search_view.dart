import 'package:bookstore_app/config.dart' as config;
import 'package:flutter/material.dart';

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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          UserAccountsDrawerHeader(
            accountName: Text('Restitutor'),
            accountEmail: Text('resti@example.com'),
            currentAccountPicture: CircleAvatar(
              child: Text('R'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('프로필'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('주문 내역'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
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