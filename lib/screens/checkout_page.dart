import 'package:flutter/material.dart';

import '../app_design.dart';
import '../data/cart_data.dart';
import '../data/order_history_data.dart';
import '../models/order_history_item.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = '카드 결제';

  int get totalPrice {
    return cartItems.fold(
      0,
          (sum, item) => sum + item.price * item.quantity,
    );
  }

  void _completePayment() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('장바구니가 비어 있습니다.'),
        ),
      );
      return;
    }

    final firstItem = cartItems.first;

    final newOrder = OrderHistoryItem(
      storeName: firstItem.storeName,
      orderType: firstItem.orderType,
      totalPrice: totalPrice,
      orderedAt: DateTime.now(),
      items: cartItems.map((item) {
        return OrderHistoryMenuItem(
          name: item.name,
          price: item.price,
          quantity: item.quantity,
        );
      }).toList(),
    );

    orderHistoryList.insert(0, newOrder);
    cartItems.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: 12),
                const Text(
                  '결제 완료되었습니다!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: kTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '주문 내역에서 방금 주문한 내용을 확인할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: kSubTextColor,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: minimalPrimaryButtonStyle(),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _paymentTile(String label) {
    final selected = _selectedPayment == label;

    return ListTile(
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? kPrimaryColor : const Color(0xFFB0B3BA),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedPayment = label;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeName = cartItems.isNotEmpty ? cartItems.first.storeName : '';
    final orderType = cartItems.isNotEmpty ? cartItems.first.orderType : '';

    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        title: const Text('결제하기'),
      ),
      body: SafeArea(
        child: cartItems.isEmpty
            ? const Center(
          child: Text(
            '결제할 상품이 없습니다.',
            style: TextStyle(
              fontSize: 16,
              color: kSubTextColor,
            ),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MinimalSquircleCard(
              radius: 30,
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
            const SizedBox(height: 14),
            MinimalSquircleCard(
              radius: 30,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주문 상품',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...cartItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
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
                ],
              ),
            ),
            const SizedBox(height: 14),
            MinimalSquircleCard(
              radius: 30,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _paymentTile('카드 결제'),
                  const Divider(height: 1, color: kBorderColor),
                  _paymentTile('현장 결제'),
                  const Divider(height: 1, color: kBorderColor),
                  _paymentTile('간편 결제'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MinimalSquircleCard(
              radius: 30,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '총 결제 금액',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: kTextColor,
                    ),
                  ),
                  Text(
                    '$totalPrice원',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kBorderColor),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completePayment,
              style: minimalPrimaryButtonStyle(),
              child: const Text(
                '결제하기',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}