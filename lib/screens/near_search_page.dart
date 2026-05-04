import 'package:flutter/material.dart';

import '../app_design.dart';
import 'store_map_webview_screen.dart';

class NearSearchPage extends StatelessWidget {
  const NearSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('근처 찾기'),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            _NearSearchBar(),
            SizedBox(height: 8),
            Expanded(
              child: _MapPlaceholder(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _NearBottomNav(),
    );
  }
}

class _NearSearchBar extends StatelessWidget {
  const _NearSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: MinimalSquircleCard(
        radius: 26,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: const SizedBox(
          height: 44,
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Color(0xFF8A8F98),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '가게, 메뉴 검색',
                style: TextStyle(
                  color: Color(0xFF8A8F98),
                  fontSize: 13,
                ),
              ),
              Spacer(),
              Icon(
                Icons.tune,
                color: Color(0xFF8A8F98),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: kSoftShadow,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: kSquircleShape(radius: 30),
          ),
          child: Container(
            width: double.infinity,
            height: 320,
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F7FF),
              shape: kSquircleShape(radius: 30),
            ),
            child: const InlineStoreMapWebView(),
          ),
        ),
      ),
    );
  }
}

class _NearBottomNav extends StatelessWidget {
  const _NearBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.place),
          label: '근처 찾기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
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
        } else if (index == 2) {
          Navigator.pushNamed(context, '/favorites');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/orders');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/mypage');
        }
      },
    );
  }
}