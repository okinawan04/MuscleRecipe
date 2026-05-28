import 'package:flutter/material.dart';
import 'package:muscle_recipe/recipe.dart';
import '../data/recipe_data.dart';
import '../services/ai_recipe_service.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedGenres = [];
  String _searchQuery = '';
  
  // 🤖 AI生成レシピの状態管理
  bool _isLoading = false;
  List<Recipe> _aiRecipes = [];
  bool _showAiRecipes = false;

  // ジャンルのリスト
  final List<String> _genres = ['すべて', '肉料理', '魚料理', '揚げ物', '飲み物', 'サラダ'];

  // 緩やかな検索判定（部分一致を более柔軟な方法で）
  bool _matchesSearch(String text, String query) {
    if (query.isEmpty) return true;

    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    // 完全一致
    if (textLower.contains(queryLower)) return true;

    // 検索語を分割して個別にチェック
    final tokens = queryLower
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .toList();
    if (tokens.isEmpty) return true;

    for (final token in tokens) {
      if (textLower.contains(token)) return true;
    }

    // 複合語の肉キーワードでは「肉」単体でのヒットを無効化する
    // 例: "鶏肉" -> "鶏" は検索対象にするが "肉" だけでは他の肉にマッチしないようにする
    final queryChars = <String>{};
    for (final token in tokens) {
      if (token.length == 1) {
        queryChars.add(token);
        continue;
      }

      for (var i = 0; i < token.length; i++) {
        final char = token[i];
        if (char == '肉' && i > 0) continue;
        queryChars.add(char);
      }
    }
    if (queryChars.isEmpty) return true;

    return queryChars.any((char) => textLower.contains(char));
  }

  // フィルタリングされたレシピを取得
  List<Recipe> get filteredRecipes {
    return sampleRecipes.where((recipe) {
      // 検索フィルタ（緩やかな判定）
      final matchesSearch =
          _searchQuery.isEmpty ||
          _matchesSearch(recipe.name, _searchQuery) ||
          recipe.ingredients.any(
            (ingredient) => _matchesSearch(ingredient, _searchQuery),
          );

      // ジャンルフィルタ（複数選択対応）
      final matchesGenre =
          _selectedGenres.isEmpty ||
          _selectedGenres.contains('すべて') ||
          _selectedGenres.contains(recipe.genre);

      return matchesSearch && matchesGenre;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('レシピ一覧の使い方'),
          content: const Text(
            'この画面では、料理名または材料名で検索できます。\n'
            'ジャンルチップをタップすると絞り込みが可能です。\n'
            '検索ボックスに「鶏肉」などを入力すると、該当するレシピを表示します。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _onGenreSelected(String genre) {
    setState(() {
      if (genre == 'すべて') {
        _selectedGenres = ['すべて'];
      } else {
        // 「すべて」が選択されていたら削除
        _selectedGenres.remove('すべて');

        if (_selectedGenres.contains(genre)) {
          _selectedGenres.remove(genre);
          // 選択が空になったら「すべて」に戻す
          if (_selectedGenres.isEmpty) {
            _selectedGenres = ['すべて'];
          }
        } else {
          _selectedGenres.add(genre);
        }
      }
    });
  }

  bool _isGenreSelected(String genre) {
    if (_selectedGenres.isEmpty) return genre == 'すべて';
    return _selectedGenres.contains(genre);
  }

  /// 🤖 AI生成レシピボタンを押したときの処理
  Future<void> _generateAiRecipes() async {
    setState(() {
      _isLoading = true;
      _showAiRecipes = true;
    });

    try {
      final aiService = AiRecipeService();
      final recipes = await aiService.generateRecipesFromInventory(
        userPreferences: '高タンパク質・低脂肪',
      );

      if (mounted) {
        setState(() {
          _aiRecipes = recipes;
          _isLoading = false;
        });

        if (recipes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('レシピを生成できませんでした。冷蔵庫に食材を追加してください。'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ一覧'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'ヘルプ',
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _showAiRecipes ? _buildAiRecipesView() : _buildNormalRecipesView(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 通常のレシピ一覧表示
  Widget _buildNormalRecipesView() {
    return Column(
      children: [
        // 検索バー
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '料理名または材料名で検索',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // ジャンルソート（スクロール可能）
        SizedBox(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            itemBuilder: (context, index) {
              final genre = _genres[index];
              final isSelected = _isGenreSelected(genre);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    genre,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    _onGenreSelected(genre);
                  },
                  selectedColor: Colors.green[200],
                  checkmarkColor: Colors.green[800],
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // レシピリスト
        Expanded(
          child: filteredRecipes.isEmpty
              ? const Center(
                  child: Text(
                    '該当するレシピがありません',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return _RecipeCard(
                      recipe: recipe,
                      searchQuery: _searchQuery,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 🤖 AI生成レシピ表示ビュー
  Widget _buildAiRecipesView() {
    return Column(
      children: [
        // ヘッダー
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[50],
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI提案レシピ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '冷蔵庫の食材から作れるレシピをAIが提案しました',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showAiRecipes = false;
                  });
                },
              ),
            ],
          ),
        ),

        // ローディングまたはレシピ表示
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _aiRecipes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _aiRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _aiRecipes[index];
                        return _RecipeCard(
                          recipe: recipe,
                          searchQuery: '',
                        );
                      },
                    ),
        ),
      ],
    );
  }

  /// ローディング状態の UI
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'AIがレシピを生成中...',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'これには数秒かかることがあります',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// 空状態の UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'レシピを生成できませんでした',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '冷蔵庫に食材を追加してから試してください',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAiRecipes = false;
              });
            },
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }

  /// FAB の構築
  Widget _buildFloatingActionButton() {
    if (_showAiRecipes) {
      return FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showAiRecipes = false;
          });
        },
        label: const Text('通常表示に戻す'),
        icon: const Icon(Icons.restaurant_menu),
        backgroundColor: Colors.green,
      );
    } else {
      return FloatingActionButton.extended(
        onPressed: _isLoading ? null : _generateAiRecipes,
        label: const Text('AI提案を見る'),
        icon: const Icon(Icons.auto_awesome),
        backgroundColor: _isLoading ? Colors.grey : Colors.amber,
      );
    }
  }
}

// レシピカードウィジェット（長押し/ホバー対応）
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String searchQuery;

  const _RecipeCard({required this.recipe, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showIngredientsTooltip(context),
      onExit: (_) => _hideIngredientsTooltip(context),
      child: GestureDetector(
        onLongPress: () => _showIngredientsTooltip(context),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.restaurant, size: 30),
            ),
            title: Text(
              recipe.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${recipe.calories}kcal • タンパク質 ${recipe.protein}g'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recipe.genre,
                    style: TextStyle(fontSize: 12, color: Colors.green[800]),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showIngredientsTooltip(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.kitchen, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    const Text(
                      '材料',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: recipe.ingredients.map((ingredient) {
                    final isHighlighted =
                        searchQuery.isNotEmpty &&
                        ingredient.toLowerCase().contains(
                          searchQuery.toLowerCase(),
                        );
                    return Chip(
                      label: Text(
                        ingredient,
                        style: TextStyle(
                          color: isHighlighted ? Colors.red : Colors.black87,
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      backgroundColor: isHighlighted
                          ? Colors.red[50]
                          : Colors.grey[100],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // 一定時間後に非表示にする（PC用）
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _hideIngredientsTooltip(BuildContext context) {
    // ホバー解除時の処理が必要な場合はここに追加
  }
}