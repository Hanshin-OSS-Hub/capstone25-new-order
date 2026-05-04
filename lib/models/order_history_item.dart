class OrderHistoryItem {
  final String storeName;
  final String orderType;
  final int totalPrice;
  final DateTime orderedAt;
  final List<OrderHistoryMenuItem> items;

  OrderHistoryItem({
    required this.storeName,
    required this.orderType,
    required this.totalPrice,
    required this.orderedAt,
    required this.items,
  });
}

class OrderHistoryMenuItem {
  final String name;
  final int price;
  final int quantity;

  OrderHistoryMenuItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

