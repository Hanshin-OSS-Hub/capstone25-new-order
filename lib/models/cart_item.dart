class CartItem {
  final String storeId;
  final String storeName;
  final String orderType;

  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.storeId,
    required this.storeName,
    required this.orderType,
    required this.name,
    required this.price,
    required this.quantity,
  });
}