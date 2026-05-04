import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_design.dart';
import '../models/favorite_store.dart';
import 'mypage_screen.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  final List<FavoriteStore> _favoriteStores = [
    FavoriteStore(
      name: '맛있는 버거집',
      description: '버거 · 패스트푸드',
      imageAsset: 'assets/images/Home_Burger.png',
    ),
    FavoriteStore(
      name: '우리 동네 덮밥집',
      description: '한식 · 덮밥',
      imageAsset: 'assets/images/Home_Korea.png',
    ),
    FavoriteStore(
      name: '로컬 커피',
      description: '카페 · 디저트',
      imageAsset: 'assets/images/Home_Desert.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyPageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('찜'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isLoggedIn
            ? Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '찜한 매장',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _favoriteStores.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final store = _favoriteStores[index];

                    return MinimalSquircleCard(
                      radius: 28,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              store.imageAsset,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  store.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kSubTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Color(0xFFFF4D4F),
                            ),
                            onPressed: () {
                              setState(() {
                                _favoriteStores.removeAt(index);
                              });

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '"${store.name}" 찜을 해제했습니다.',
                                  ),
                                  duration:
                                  const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Color(0xFFB0B3BA),
                ),
                const SizedBox(height: 12),
                const Text(
                  '찜한 내역이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '로그인 후 나의 찜 내역을 확인할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: kSubTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    '로그인 하러 가기',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _FavoritesBottomNav(),
    );
  }
}

class _FavoritesBottomNav extends StatelessWidget {
  const _FavoritesBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place_outlined),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/near');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/orders');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/mypage');
        }
      },
    );
  }
}