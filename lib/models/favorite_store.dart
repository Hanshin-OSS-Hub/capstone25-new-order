class FavoriteStore {
  final String name;
  final String description;
  final String imageAsset;
  bool isFavorite;

  FavoriteStore({
    required this.name,
    required this.description,
    this.imageAsset = 'assets/images/default_store.png',
    this.isFavorite = true,
  });
}