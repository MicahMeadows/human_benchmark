class GameSelectOption {
  final String gameName;
  final String route;
  final int cost;

  GameSelectOption({
    required this.gameName,
    required this.route,
    this.cost = 1, // Default cost is 1 credit
  });
}
