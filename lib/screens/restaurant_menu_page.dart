import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_design.dart';
import '../data/cart_data.dart';
import '../models/cart_item.dart';
import '../models/restaurant.dart';
import 'cart_page.dart';
import 'mypage_screen.dart';

class RestaurantMenuPage extends StatelessWidget {
  final Restaurant restaurant;
  final String orderType;

  const RestaurantMenuPage({
    super.key,
    required this.restaurant,
    required this.orderType,
  });

  Future<void> _addToCart(
      BuildContext context,
      RestaurantMenuItem item,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Expanded(
                child: Text(
                  '로그인 후 진행해주세요.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton(
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyPageScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (cartItems.isNotEmpty) {
      final first = cartItems.first;

      final isDifferentStore = first.storeId != restaurant.id;
      final isDifferentOrderType = first.orderType != orderType;

      if (isDifferentStore || isDifferentOrderType) {
        cartItems.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('다른 매장 또는 주문 방식의 장바구니를 비우고 새로 담았습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    bool found = false;

    for (final cartItem in cartItems) {
      if (cartItem.storeId == restaurant.id &&
          cartItem.orderType == orderType &&
          cartItem.name == item.name) {
        cartItem.quantity++;
        found = true;
        break;
      }
    }

    if (!found) {
      cartItems.add(
        CartItem(
          storeId: restaurant.id,
          storeName: restaurant.name,
          orderType: orderType,
          name: item.name,
          price: item.price,
          quantity: 1,
        ),
      );
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${item.name}" 을(를) 장바구니에 담았습니다.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '장바구니로 이동',
          textColor: Colors.yellow,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: Text(restaurant.name),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MinimalSquircleCard(
              radius: 30,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      restaurant.imageAsset,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: kTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          orderType,
                          style: const TextStyle(
                            fontSize: 13,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kSubTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '메뉴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kTextColor,
              ),
            ),
            const SizedBox(height: 12),

            ...restaurant.menus.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MinimalSquircleCard(
                  radius: 28,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF2F4FF),
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Icon(
                          Icons.lunch_dining,
                          size: 30,
                          color: kSubTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: kTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kSubTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${item.price}원',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        color: kPrimaryColor,
                        onPressed: () => _addToCart(context, item),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}