class Recipe {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final List<String> instructions;
  final String imageUrl;
  final int cookingTime;
  final String difficulty;
  final String genre; // 肉的料理、鱼料理、油炸等

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
    required this.imageUrl,
    required this.cookingTime,
    required this.difficulty,
    required this.genre,
  });
}
