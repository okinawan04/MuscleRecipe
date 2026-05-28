import 'package:flutter/material.dart';

import 'package:muscle_recipe/recipe.dart';
import '../data/recipe_data.dart';
import '../services/ai_recipe_service.dart';
import 'package:muscle_recipe/database_helper.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AiRecipeService _aiService = AiRecipeService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  // ===== 状態変数 =====
  List<String> _selectedGenres = [];
  String _searchQuery = '';
  
  /// ハードコードされたサンプルレシピ
  List<Recipe> _sampleRecipes = sampleRecipes;
  
  /// AI生成されたレシピ
  List<Recipe> _aiGeneratedRecipes = [];
  
  /// ローディング状態フラグ
  bool _isLoading = false;
  
  /// エラーメッセージ
  String? _errorMessage;

  // ジャンルのリスト
  final List<String> _genres = ['すべて', '肉料理', '魚料理', '揚げ物', '飲み物', 'サラダ'];

  // ===== ライフサイクル =====
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// アプリケーション初期化
  /// - サンプル在庫データをDBに挿入（開発用）
  Future<void> _initializeApp() async {
    try {
      print('🚀 Initializing MuscleRecipe app...');
      
      // サンプル在庫データを挿入（初回のみ）
      print('📦 Calling insertSampleInventory()...');
      await _db.insertSampleInventory();
      print('✅ insertSampleInventory() completed');
      
      // 在庫を確認
      print('🔍 Fetching current inventory...');
      final inventory = await _db.getCurrentInventory();
      print('✅ Inventory loaded: ${inventory.length} items');
      for (final item in inventory) {
        print('  - ${item['ingredient_name']}: ${item['quantity']}${item['unit']}');
      }
      
      // プロンプト用テキストを確認
      print('📝 Generating inventory prompt text...');
      final promptText = await _db.getInventoryPromptText();
      print('✅ Inventory prompt text:\n$promptText');
      
      setState(() {
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      print('❌ Initialization error: $e');
      print('Stack trace: $stackTrace');
      
      final errorMsg = '初期化エラー:\n$e\n\nStack: $stackTrace';
      
      setState(() {
        _errorMessage = errorMsg;
      });
      
      // エラーダイアログを表示
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('初期化エラー'),
              content: SingleChildScrollView(
                child: Text(errorMsg),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===== データフィルタリング =====

  /// 緩やかな検索判定（部分一致）
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

    return false;
  }

  /// フィルタリング済みレシピを取得
  /// 
  /// 優先順位:
  /// 1. サンプルレシピ（ユーザー登録済み）
  /// 2. AI生成レシピ（新鮮な順）
  List<Recipe> get filteredRecipes {
    final allRecipes = [..._sampleRecipes, ..._aiGeneratedRecipes];

    return allRecipes.where((recipe) {
      // 検索フィルタ
      final matchesSearch =
          _searchQuery.isEmpty ||
          _matchesSearch(recipe.name, _searchQuery) ||
          recipe.ingredients.any(
            (ingredient) => _matchesSearch(ingredient, _searchQuery),
          );

      // ジャンルフィルタ
      final matchesGenre =
          _selectedGenres.isEmpty ||
          _selectedGenres.contains('すべて') ||
          _selectedGenres.contains(recipe.genre);

      return matchesSearch && matchesGenre;
    }).toList();
  }

  // ===== イベントハンドラ =====

  /// ジャンル選択時の処理
  void _onGenreSelected(String genre) {
    setState(() {
      if (genre == 'すべて') {
        _selectedGenres = ['すべて'];
      } else {
        _selectedGenres.remove('すべて');

        if (_selectedGenres.contains(genre)) {
          _selectedGenres.remove(genre);
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

  /// AI レシピ生成処理（FAB クリック時）
  /// 
  /// 処理フロー:
  /// 1. ローディング状態を有効化
  /// 2. Gemini API へリクエスト
  /// 3. レスポンスを _aiGeneratedRecipes に追加
  /// 4. スナックバーで結果を通知
  Future<void> _generateAiRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 Starting AI recipe generation...');

      // AI レシピを生成
      final recipes = await _aiService.generateRecipesFromInventory(
        userPreferences: '高タンパク質・低炭水化物',
      );

      setState(() {
        _aiGeneratedRecipes = recipes;
        _isLoading = false;

        if (recipes.isEmpty) {
          _errorMessage = 'レシピを生成できませんでした。在庫を確認してください。';
          _showSnackBar('⚠️ レシピ生成に失敗しました', isError: true);
        } else {
          _showSnackBar('✅ ${recipes.length}個のレシピを生成しました!');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'エラーが発生しました: $e';
      });

      _showSnackBar('❌ エラー: $e', isError: true);
      print('❌ Error: $e');
    }
  }

  /// 柔軟なレシピ生成（+1, 2 食材で作れるレシピ）
  Future<void> _generateFlexibleRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await _aiService.generateFlexibleRecipes(
        userPreferences: '高タンパク質',
      );

      setState(() {
        _aiGeneratedRecipes = recipes;
        _isLoading = false;

        if (recipes.isEmpty) {
          _showSnackBar('レシピを生成できませんでした', isError: true);
        } else {
          _showSnackBar('✅ 柔軟なレシピ ${recipes.length}個を生成しました!');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'エラーが発生しました: $e';
      });

      _showSnackBar('❌ エラー', isError: true);
    }
  }

  /// AI生成レシピをクリア
  void _clearAiRecipes() {
    setState(() {
      _aiGeneratedRecipes.clear();
      _errorMessage = null;
    });
    _showSnackBar('AI生成レシピをクリアしました');
  }

  /// スナックバーを表示
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ヘルプダイアログを表示
  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('レシピ一覧の使い方'),
          content: const Text(
            '【基本操作】\n'
            '• 検索ボックスで料理名や材料名で検索できます\n'
            '• ジャンルチップをタップして絞り込み\n\n'
            '【AI レシピ生成】\n'
            '• 右下の「✨」ボタンをタップ\n'
            '• 冷蔵庫の在庫から作れるレシピを自動生成\n'
            '• 複数回タップするたびに新しいレシピが生成されます\n\n'
            '【その他】\n'
            '• 各レシピをタップして詳細を確認\n'
            '• 人数設定で栄養情報を自動計算',
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

  // ===== UI ビルダー =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レシピ一覧'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'ヘルプ',
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // メインコンテンツ
          Column(
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

              // ジャンルフィルタ
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
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (selected) {
                          _onGenreSelected(genre);
                        },
                        selectedColor: Colors.green[200],
                        checkmarkColor: Colors.green[800],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // AI レシピセクションのヘッダー
              if (_aiGeneratedRecipes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '✨ AI生成レシピ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _clearAiRecipes,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('クリア'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                        ),
                      ),
                    ],
                  ),
                ),

              // レシピリスト
              Expanded(
                child: filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _aiGeneratedRecipes.isEmpty
                                  ? '検索に一致するレシピがありません'
                                  : 'AI生成レシピをご覧ください',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];

                          return _RecipeCard(
                            recipe: recipe,
                            searchQuery: _searchQuery,
                            isAiGenerated: recipe.isAiGenerated,
                          );
                        },
                      ),
              ),
            ],
          ),

          // エラーメッセージ表示
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // FAB: AI レシピ生成ボタン
      floatingActionButton: _buildFAB(),
    );
  }

  /// FAB ビルダー（ローディング中は使用不可）
  Widget _buildFAB() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // セカンダリ FAB: 柔軟なレシピ生成
        if (!_isLoading)
          FloatingActionButton.small(
            heroTag: 'flexible_recipe_fab',
            onPressed: _generateFlexibleRecipes,
            backgroundColor: Colors.orange[400],
            tooltip: '+1, 2食材で作れるレシピ',
            child: const Icon(Icons.add),
          ),
        const SizedBox(height: 8),

        // プライマリ FAB: AI レシピ生成
        FloatingActionButton(
          heroTag: 'ai_recipe_fab',
          onPressed: _isLoading ? null : _generateAiRecipes,
          backgroundColor: _isLoading ? Colors.grey : Colors.green,
          tooltip: 'AI レシピを生成',
          child: _isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7),
                    ),
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.auto_awesome),
        ),
      ],
    );
  }
}

// ===== レシピカードウィジェット =====

class _RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final String searchQuery;
  final bool isAiGenerated;

  const _RecipeCard({
    required this.recipe,
    required this.searchQuery,
    required this.isAiGenerated,
  });

  @override
  State<_RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<_RecipeCard> {
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return MouseRegion(
      onEnter: (_) => _showIngredientsTooltip(context),
      onExit: (_) => _hideIngredientsTooltip(),
      child: GestureDetector(
        onLongPress: () => _showIngredientsTooltip(context),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: widget.isAiGenerated ? Colors.amber[50] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.isAiGenerated
                  ? const Icon(Icons.auto_awesome, size: 30, color: Colors.amber)
                  : const Icon(Icons.restaurant, size: 30, color: Colors.grey),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isAiGenerated)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '${recipe.calories}kcal • タンパク質 ${recipe.protein}g',
              overflow: TextOverflow.ellipsis,
            ),
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
                const Icon(Icons.arrow_forward_ios, size: 16),
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

    _overlayEntry = OverlayEntry(
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
                  children: widget.recipe.ingredients.map((ingredient) {
                    final isHighlighted = widget.searchQuery.isNotEmpty &&
                        ingredient.toLowerCase().contains(
                          widget.searchQuery.toLowerCase(),
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

    overlay.insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
    });
  }

  void _hideIngredientsTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
