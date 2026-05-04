import 'package:flutter/material.dart';

import '../app_design.dart';
import '../data/cart_data.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int get totalPrice {
    return cartItems.fold(
      0,
          (sum, item) => sum + item.price * item.quantity,
    );
  }

  void _increaseQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems.removeAt(index);
      }
    });
  }

  void _goToCheckout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('장바구니가 비어 있습니다.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CheckoutPage(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? storeName =
    cartItems.isNotEmpty ? cartItems.first.storeName : null;
    final String? orderType =
    cartItems.isNotEmpty ? cartItems.first.orderType : null;

    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('장바구니'),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? const Center(
          child: Text(
            '장바구니가 비어 있습니다.',
            style: TextStyle(
              fontSize: 16,
              color: kSubTextColor,
            ),
          ),
        )
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: MinimalSquircleCard(
                radius: 28,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.storefront,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$storeName · $orderType',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MinimalSquircleCard(
                      radius: 28,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.price * item.quantity}원',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _decreaseQuantity(index),
                                icon: const Icon(Icons.remove_circle),
                                color: Color(0xFFB0B3BA),
                              ),
                              Container(
                                width: 32,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                  color: kPrimaryColor,
                                  shape: ContinuousRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _increaseQuantity(index),
                                icon: const Icon(Icons.add_circle),
                                color: Color(0xFFB0B3BA),
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
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: kBorderColor),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 주문 금액',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: kTextColor,
                        ),
                      ),
                      Text(
                        '$totalPrice원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _goToCheckout,
                      style: minimalPrimaryButtonStyle(),
                      child: const Text(
                        '주문 / 결제하기',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}