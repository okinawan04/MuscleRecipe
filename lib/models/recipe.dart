import 'dart:convert';

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
  final String genre;
  
  /// AI生成フラグ（Gemini APIから生成されたレシピか）
  final bool isAiGenerated;

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
    this.isAiGenerated = false,
  });

  /// Gemini APIのレスポンス（JSON）からRecipeオブジェクトを生成
  /// APIレスポンス形式:
  /// {
  ///   "id": "unique_id",
  ///   "name": "レシピ名",
  ///   "description": "説明",
  ///   "calories": 300,
  ///   "protein": 25,
  ///   "carbs": 30,
  ///   "fat": 10,
  ///   "ingredients": ["材料1", "材料2"],
  ///   "instructions": ["手順1", "手順2"],
  ///   "cookingTime": 20,
  ///   "difficulty": "簡単",
  ///   "genre": "肉料理"
  /// }
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'レシピ',
      description: json['description']?.toString() ?? '',
      calories: _parseInteger(json['calories']),
      protein: _parseInteger(json['protein']),
      carbs: _parseInteger(json['carbs']),
      fat: _parseInteger(json['fat']),
      ingredients: _parseList(json['ingredients']),
      instructions: _parseList(json['instructions']),
      imageUrl: json['imageUrl']?.toString() ?? 'https://example.com/recipe.jpg',
      cookingTime: _parseInteger(json['cookingTime']),
      difficulty: json['difficulty']?.toString() ?? '普通',
      genre: json['genre']?.toString() ?? '未分類',
      isAiGenerated: json['isAiGenerated'] as bool? ?? true,
    );
  }

  /// 複数のJSONを一括でRecipeリストに変換（APIレスポンス用）
  static List<Recipe> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map((json) => Recipe.fromJson(json))
        .toList();
  }

  /// Recipeオブジェクトを JSON Map に変換（DB保存用）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': jsonEncode(ingredients),
      'instructions': jsonEncode(instructions),
      'imageUrl': imageUrl,
      'cookingTime': cookingTime,
      'difficulty': difficulty,
      'genre': genre,
      'isAiGenerated': isAiGenerated ? 1 : 0,
    };
  }

  /// ===== ヘルパーメソッド =====
  
  /// 数値を安全にパース（nullの場合は0を返す）
  static int _parseInteger(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// リストを安全にパース（nullの場合は空リストを返す）
  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {}
      return [];
    }
    return [];
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, protein: $protein g, isAiGenerated: $isAiGenerated)';
  }
}