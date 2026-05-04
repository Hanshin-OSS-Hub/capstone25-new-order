import '../models/order_history_item.dart';

// 앱 실행 중 공유되는 임시 주문내역
final List<OrderHistoryItem> orderHistoryList = [
  OrderHistoryItem(
    storeName: '맛있는 버거집',
    orderType: '매장식사',
    totalPrice: 13300,
    orderedAt: DateTime(2025, 11, 14, 12, 30),
    items: [
      OrderHistoryMenuItem(
        name: '치즈버거 세트',
        price: 8900,
        quantity: 1,
      ),
      OrderHistoryMenuItem(
        name: '감자튀김',
        price: 2200,
        quantity: 1,
      ),
      OrderHistoryMenuItem(
        name: '콜라',
        price: 2200,
        quantity: 1,
      ),
    ],
  ),
  OrderHistoryItem(
    storeName: '로컬 커피',
    orderType: '포장주문',
    totalPrice: 12400,
    orderedAt: DateTime(2025, 10, 30, 15, 10),
    items: [
      OrderHistoryMenuItem(
        name: '아이스 아메리카노',
        price: 4500,
        quantity: 2,
      ),
      OrderHistoryMenuItem(
        name: '초콜릿 케이크',
        price: 3400,
        quantity: 1,
      ),
    ],
  ),
  OrderHistoryItem(
    storeName: '한식당 한그릇',
    orderType: '포장주문',
    totalPrice: 15900,
    orderedAt: DateTime(2025, 8, 2, 18, 20),
    items: [
      OrderHistoryMenuItem(
        name: '김치볶음밥',
        price: 8900,
        quantity: 1,
      ),
      OrderHistoryMenuItem(
        name: '된장국',
        price: 3000,
        quantity: 1,
      ),
      OrderHistoryMenuItem(
        name: '계란후라이 추가',
        price: 1000,
        quantity: 4,
      ),
    ],
  ),
  OrderHistoryItem(
    storeName: '피자대학',
    orderType: '매장식사',
    totalPrice: 23900,
    orderedAt: DateTime(2025, 6, 29, 19, 0),
    items: [
      OrderHistoryMenuItem(
        name: '페퍼로니 피자',
        price: 19900,
        quantity: 1,
      ),
      OrderHistoryMenuItem(
        name: '갈릭디핑소스',
        price: 1000,
        quantity: 2,
      ),
      OrderHistoryMenuItem(
        name: '음료',
        price: 2000,
        quantity: 1,
      ),
    ],
  ),
];