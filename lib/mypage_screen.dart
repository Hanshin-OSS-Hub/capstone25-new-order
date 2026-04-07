// lib/mypage_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isLoggedIn = false;
  String? _token;
  String? _userId;
  bool _isLoading = false;

  // 안드로이드 에뮬레이터 기준 Flask 서버 주소
  final String baseUrl = 'http://10.0.2.2:5000';

  @override
  void initState() {
    super.initState();
    _loadTokenAndProfile();
  }

  // ---------------- JWT 관련 메서드들 ----------------

  Future<void> _loadTokenAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt_token');

    if (savedToken != null) {
      setState(() {
        _token = savedToken;
      });
      await _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    if (_token == null) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/profile');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userId = data['user_id'];
          _isLoggedIn = true;
        });
      } else if (response.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('jwt_token');
        setState(() {
          _isLoggedIn = false;
          _token = null;
          _userId = null;
        });
      }
    } catch (e) {
      debugPrint('profile error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _goToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(baseUrl: baseUrl),
      ),
    );

    if (result == true) {
      await _loadTokenAndProfile();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    setState(() {
      _isLoggedIn = false;
      _token = null;
      _userId = null;
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_isLoggedIn)
            TextButton(
              onPressed: _logout,
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Color(0xFF4466DB)),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            _ProfileCard(
              isLoggedIn: _isLoggedIn,
              userId: _userId,
              onLoginTap: _goToLogin,
            ),
            const SizedBox(height: 16),
            const _MyMenuSection(),
          ],
        ),
      ),
      bottomNavigationBar: const _MyPageBottomNav(),
    );
  }
}

/// ---------------------- 프로필 카드 ----------------------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    super.key,
    required this.isLoggedIn,
    required this.onLoginTap,
    this.userId,
  });

  final bool isLoggedIn;
  final VoidCallback onLoginTap;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    // 로그인 안 되어 있을 때
    if (!isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFF2F4FF),
              child: Icon(
                Icons.person_outline,
                color: Color(0xFF727784),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                '로그인이 필요합니다.',
                style: TextStyle(
                  color: Color(0xFF1C1C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onLoginTap,
              child: const Text(
                '로그인',
                style: TextStyle(
                  color: Color(0xFF4466DB),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 로그인 된 상태 카드
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFF2F4FF),
            child: Icon(
              Icons.person,
              color: Color(0xFF727784),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userId ?? '홍길동',  // 토큰에서 온 userId, 없으면 예전처럼 홍길동
                  style: const TextStyle(
                    color: Color(0xFF1C1C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '010-1234-5678', // 나중에 서버에서 받아오고 싶으면 여기만 바꾸면 됨
                  style: TextStyle(
                    color: Color(0xFF727784),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 프로필 수정 화면
            },
            child: const Text(
              '프로필 수정',
              style: TextStyle(
                color: Color(0xFF4466DB),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------- 메뉴 리스트 ----------------------

class _MyMenuSection extends StatelessWidget {
  const _MyMenuSection();

  @override
  Widget build(BuildContext context) {
    final items = [
      _MyMenuItemData(
        icon: Icons.location_on_outlined,
        title: '주소 관리',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.campaign_outlined,
        title: '진행중인 이벤트',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.credit_card_outlined,
        title: '결제수단 관리',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.card_membership_outlined,
        title: '멤버십 가입',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.help_outline,
        title: '자주 묻는 질문',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.headset_mic_outlined,
        title: '고객 지원',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.settings_outlined,
        title: '설정',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.notifications_none,
        title: '공지사항',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.description_outlined,
        title: '약관 및 정책',
        onTap: () {},
      ),
      _MyMenuItemData(
        icon: Icons.privacy_tip_outlined,
        title: '개인정보 처리방침',
        onTap: () {},
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MyMenuTile(data: items[i]),
            if (i != items.length - 1) const Divider(height: 1),
          ]
        ],
      ),
    );
  }
}

class _MyMenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MyMenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _MyMenuTile extends StatelessWidget {
  final _MyMenuItemData data;

  const _MyMenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        data.icon,
        color: const Color(0xFF727784),
      ),
      title: Text(
        data.title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1C1C1C),
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFB0B3BA),
      ),
      onTap: data.onTap,
    );
  }
}

/// ---------------------- 마이페이지 하단 네비게이션 ----------------------
/// (원본이랑 똑같이 보이게 하되, 네비게이션은 Named route 사용)

class _MyPageBottomNav extends StatelessWidget {
  const _MyPageBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
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
          icon: Icon(Icons.favorite_border),
          label: '찜',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/near');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/favorites');
        } else if (index == 3) {
          Navigator.pushNamed(context, '/orders');
        }
        // index == 4 는 현재 페이지
      },
    );
  }
}
