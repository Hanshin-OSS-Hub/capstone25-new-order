class SearchRestaurant {
  final String name;
  final String description;
  final String category;
  final List<String> tags;

  final double distance;
  final int myOrderCount;
  final int totalOrderCount;
  final int createdOrder;
  final int recommendScore;

  const SearchRestaurant({
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    this.distance = 999,
    this.myOrderCount = 0,
    this.totalOrderCount = 0,
    this.createdOrder = 0,
    this.recommendScore = 0,
  });
}