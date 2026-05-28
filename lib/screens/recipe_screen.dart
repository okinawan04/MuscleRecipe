import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:muscle_recipe/database_helper.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    if (kIsWeb) {
      // Web環境ではDBが使用できないため、すぐに完了
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final recipes = await DatabaseHelper.instance.getRecipes();
      if (mounted) {
        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recipes.isEmpty
                ? _buildEmptyState(context)
                : _buildRecipeList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          const Text(
            'まだレシピが登録されていません',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            '初期データを作成しました。再起動すると反映されます。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    return ListView.separated(
      itemCount: _recipes.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final recipe = _recipes[index];
        return ListTile(
          title: Text(recipe['name'] as String),
          subtitle: Text(recipe['description'] as String? ?? ''),
          trailing: Text('${recipe['servings'] ?? 1}人分'),
          isThreeLine: true,
        );
      },
    );
  }
}
