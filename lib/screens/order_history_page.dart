import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_design.dart';
import '../data/order_history_data.dart';
import 'mypage_screen.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

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

  String _formatDateTime(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('주문 내역'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_isLoggedIn
            ? _LoginRequiredView(
          onLoginTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyPageScreen(),
              ),
            );
          },
        )
            : orderHistoryList.isEmpty
            ? const Center(
          child: Text(
            '주문 내역이 없습니다.',
            style: TextStyle(
              fontSize: 15,
              color: kSubTextColor,
            ),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orderHistoryList.length,
          separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orderHistoryList[index];

            return MinimalSquircleCard(
              radius: 28,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${order.orderType} · ${_formatDateTime(order.orderedAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kSubTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) {
                    return Padding(
                      padding:
                      const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.name} x ${item.quantity}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: kTextColor,
                              ),
                            ),
                          ),
                          Text(
                            '${item.price * item.quantity}원',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 결제 금액',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${order.totalPrice}원',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const _OrderBottomNav(),
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  final VoidCallback onLoginTap;

  const _LoginRequiredView({
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFFB0B3BA),
            ),
            const SizedBox(height: 12),
            const Text(
              '주문 내역이 없습니다.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '로그인 후 나의 주문 내역을 확인할 수 있어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: kSubTextColor,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onLoginTap,
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
    );
  }
}

class _OrderBottomNav extends StatelessWidget {
  const _OrderBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
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
          icon: Icon(Icons.receipt_long),
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
        } else if (index == 2) {
          Navigator.pushNamed(context, '/favorites');
        } else if (index == 4) {
          Navigator.pushNamed(context, '/mypage');
        }
      },
    );
  }
}