class RestaurantMenuItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String? imageAsset;

  const RestaurantMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageAsset,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String category;
  final String address;
  final String description;
  final String imageAsset;
  final List<RestaurantMenuItem> menus;

  const Restaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.description,
    required this.imageAsset,
    required this.menus,
  });
}