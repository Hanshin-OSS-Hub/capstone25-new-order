import 'package:flutter/material.dart';

import '../app_design.dart';
import '../models/restaurant.dart';
import 'restaurant_menu_page.dart';

class StoreOrderTypePage extends StatelessWidget {
  final Restaurant restaurant;

  const StoreOrderTypePage({
    super.key,
    required this.restaurant,
  });

  void _goToMenuPage(BuildContext context, String orderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantMenuPage(
          restaurant: restaurant,
          orderType: orderType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('매장 정보'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  restaurant.imageAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MinimalSquircleCard(
                  radius: 30,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        restaurant.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kSubTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: kSubTextColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: kSubTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        restaurant.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MinimalSquircleCard(
                  radius: 30,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '식사 방식을 선택해주세요',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: kTextColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _goToMenuPage(context, '매장식사'),
                          style: minimalPrimaryButtonStyle(),
                          icon: const Icon(Icons.restaurant),
                          label: const Text(
                            '매장 이용',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _goToMenuPage(context, '포장주문'),
                          style: minimalOutlinedButtonStyle(),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text(
                            '포장 주문',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}