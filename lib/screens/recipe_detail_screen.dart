import 'package:flutter/material.dart';
import '../models/recipe.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int _servings = 2;

  void _setServings(int value) {
    setState(() {
      _servings = value;
    });
  }

  String _scaledIngredient(String ingredient) {
    final scale = _servings / 2;
    return ingredient.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)'), (match) {
      final original = double.parse(match.group(1)!);
      final scaled = original * scale;
      if (scaled == scaled.roundToDouble()) {
        return scaled.toInt().toString();
      }
      return scaled.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // レシピ画像
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // 説明
            Text(recipe.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // 人数設定
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '人数設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _servingsChip(2),
                        _servingsChip(3),
                        _servingsChip(4),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('現在の設定: $_servings人前'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 栄養情報
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '栄養情報',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _nutrientItem('カロリー', '${recipe.calories}kcal'),
                        _nutrientItem('タンパク質', '${recipe.protein}g'),
                        _nutrientItem('脂質', '${recipe.fat}g'),
                        _nutrientItem('炭水化物', '${recipe.carbs}g'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 調理時間・難易度
            Row(
              children: [
                Icon(Icons.timer, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('調理時間: ${recipe.cookingTime}分'),
                const SizedBox(width: 24),
                Icon(Icons.bar_chart, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('難易度: ${recipe.difficulty}'),
              ],
            ),
            const SizedBox(height: 24),

            // 材料
            const Text(
              '材料',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
              (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_scaledIngredient(ingredient))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 作り方
            const Text(
              '作り方',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.instructions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _servingsChip(int value) {
    final selected = _servings == value;
    return ChoiceChip(
      label: Text('$value人前'),
      selected: selected,
      selectedColor: Colors.green[200],
      onSelected: (_) => _setServings(value),
    );
  }

  Widget _nutrientItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}