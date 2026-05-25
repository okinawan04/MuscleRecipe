import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MuscleRecipe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MuscleRecipe'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<FoodCategory> categories;

  List<Map<String, dynamic>> foods = [];

  bool isEditMode = false;

  void sortItemsByStockAndRegistrationOrder(List<FoodItem> items) {
    items.sort((a, b) {
      final aHasStock = a.quantity > 0;
      final bHasStock = b.quantity > 0;

      // 在庫ありを上にする
      if (aHasStock && !bHasStock) {
        return -1;
      }

      // 在庫なしを下にする
      if (!aHasStock && bHasStock) {
        return 1;
      }

      // 同じ状態なら登録順
      return a.id.compareTo(b.id);
    });
  }

  void sortAllCategoryItems() {
    for (final category in categories) {
      sortItemsByStockAndRegistrationOrder(category.items);
    }
  }

  bool get hasExpandedCategory {
    return categories.any((category) => category.isExpanded);
  }

  void closeAllCategories() {
    setState(() {
      for (final category in categories) {
        category.isExpanded = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    categories = [];

    initializeData();
  }

  Future<void> initializeData() async {
    await DatabaseHelper.instance.insertDefaultIngredients();

    await loadCategories();
  }

  Future<void> loadCategories() async {
    final vegetables = await DatabaseHelper.instance.getIngredientsByCategory(
      '野菜',
    );

    final meats = await DatabaseHelper.instance.getIngredientsByCategory('肉');

    final fishes = await DatabaseHelper.instance.getIngredientsByCategory('魚');

    final dairies = await DatabaseHelper.instance.getIngredientsByCategory(
      '乳製品・卵',
    );
    // 野菜
    List<FoodItem> vegetableItems = [];

    for (final e in vegetables) {
      final ingredientId = e['id'] as int;

      final quantity = await DatabaseHelper.instance
          .getFoodQuantityByIngredientId(ingredientId);

      final vegetableNearExpire = await DatabaseHelper.instance.isNearExpire(
        ingredientId,
      );

      vegetableItems.add(
        FoodItem(
          id: ingredientId,
          name: e['name'],
          quantity: quantity,
          isNearExpire: vegetableNearExpire,
        ),
      );
    }

    // 肉
    List<FoodItem> meatItems = [];

    for (final e in meats) {
      final ingredientId = e['id'] as int;

      final quantity = await DatabaseHelper.instance
          .getFoodQuantityByIngredientId(ingredientId);

      final meatNearExpire = await DatabaseHelper.instance.isNearExpire(
        ingredientId,
      );

      meatItems.add(
        FoodItem(
          id: ingredientId,
          name: e['name'],
          quantity: quantity,
          isNearExpire: meatNearExpire,
        ),
      );
    }

    // 魚
    List<FoodItem> fishItems = [];

    for (final e in fishes) {
      final ingredientId = e['id'] as int;

      final quantity = await DatabaseHelper.instance
          .getFoodQuantityByIngredientId(ingredientId);

      final fishNearExpire = await DatabaseHelper.instance.isNearExpire(
        ingredientId,
      );

      fishItems.add(
        FoodItem(
          id: ingredientId,
          name: e['name'],
          quantity: quantity,
          isNearExpire: fishNearExpire,
        ),
      );
    }

    // 乳製品・卵
    List<FoodItem> dairyItems = [];

    for (final e in dairies) {
      final ingredientId = e['id'] as int;

      final quantity = await DatabaseHelper.instance
          .getFoodQuantityByIngredientId(ingredientId);

      final dairyNearExpire = await DatabaseHelper.instance.isNearExpire(
        ingredientId,
      );

      dairyItems.add(
        FoodItem(
          id: ingredientId,
          name: e['name'],
          quantity: quantity,
          isNearExpire: dairyNearExpire,
        ),
      );
    }

    sortItemsByStockAndRegistrationOrder(vegetableItems);
    sortItemsByStockAndRegistrationOrder(meatItems);
    sortItemsByStockAndRegistrationOrder(fishItems);
    sortItemsByStockAndRegistrationOrder(dairyItems);

    setState(() {
      categories = [
        FoodCategory(name: '野菜', items: vegetableItems),
        FoodCategory(name: '肉', items: meatItems),
        FoodCategory(name: '魚', items: fishItems),
        FoodCategory(name: '乳製品・卵', items: dairyItems),
      ];
    });
  }

  Future<void> loadFoods() async {
    final result = await DatabaseHelper.instance.getFoods();

    setState(() {
      foods = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4A4A4A),
        child: Column(
          children: [
            // Title
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(14),

                      boxShadow: [
                        // 下側の影
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),

                        // 上側のうっすら光
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 2,
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),

                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.grey.withValues(alpha: 0.3),
                        highlightColor: Colors.grey.withValues(alpha: 0.1),
                        onTap: () {
                          setState(() {
                            isEditMode = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: const Text(
                            '編集',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Food Categories List
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return FoodCategoryWidget(
                    category: categories[index],
                    isEditMode: isEditMode,
                    onChanged: () {
                      setState(() {});
                    },
                  );
                },
              ),
            ),

            if (hasExpandedCategory)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: const Color(0xFF6A6A6A),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      onTap: closeAllCategories,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'カテゴリを閉じる',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            if (isEditMode)
              // OK Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),

                      // 立体感
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: Colors.grey.withValues(alpha: 0.2),
                        highlightColor: Colors.grey.withValues(alpha: 0.1),
                        onTap: () {
                          setState(() {
                            sortAllCategoryItems();
                            isEditMode = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class FoodCategory {
  final String name;
  final List<FoodItem> items;
  bool isExpanded;

  FoodCategory({
    required this.name,
    required this.items,
    this.isExpanded = false,
  });
}

class FoodItem {
  final int id;
  final String name;
  int quantity;
  bool isNearExpire;

  FoodItem({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.isNearExpire = false,
  });
}

class FoodCategoryWidget extends StatefulWidget {
  final FoodCategory category;
  final VoidCallback onChanged;
  final bool isEditMode;
  const FoodCategoryWidget({
    super.key,
    required this.category,
    required this.onChanged,
    required this.isEditMode,
  });

  @override
  State<FoodCategoryWidget> createState() => _FoodCategoryWidgetState();
}

class _FoodCategoryWidgetState extends State<FoodCategoryWidget> {
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName) {
      case '野菜':
        return Icons.eco;
      case '肉':
        return Icons.restaurant;
      case '魚':
        return Icons.set_meal;
      case '乳製品・卵':
        return Icons.egg_alt;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName) {
      case '野菜':
        return const Color(0xFF66BB6A);
      case '肉':
        return const Color(0xFFE57373);
      case '魚':
        return const Color(0xFF64B5F6);
      case '乳製品・卵':
        return const Color(0xFFFFD54F);

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Material(
            color: const Color(0xFF5A5A5A),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              onTap: () {
                setState(() {
                  widget.category.isExpanded = !widget.category.isExpanded;
                });
                widget.onChanged();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: _getCategoryColor(widget.category.name),
                      width: 5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(widget.category.name),
                      color: _getCategoryColor(widget.category.name),
                      size: 24,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.category.items.length}種類',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Icon(
                      widget.category.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.category.isExpanded)
          ...widget.category.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),

                      // 押した時にグレーになる
                      splashColor: Colors.grey.withValues(alpha: 0.25),
                      highlightColor: Colors.grey.withValues(alpha: 0.25),

                      // 在庫がある時だけ押せる
                      onTap: item.quantity > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    ingredientId: item.id,
                                    ingredientName: item.name,
                                  ),
                                ),
                              );
                            }
                          : null,

                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: item.isNearExpire
                                ? Colors.red
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,

                            // 在庫がある項目だけ下線
                            decoration: item.quantity > 0
                                ? TextDecoration.underline
                                : TextDecoration.none,

                            // 下線の色を文字色と同じにする
                            decorationColor: item.isNearExpire
                                ? Colors.red
                                : Colors.white,

                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 130, // 通常時も編集時も右側の幅を固定
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // −ボタンの場所は常に確保。通常時は見えない
                        Visibility(
                          visible: widget.isEditMode,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () async {
                              if (item.quantity > 0) {
                                setState(() {
                                  item.quantity--;
                                });

                                // ingredientId はここで1回だけ取得する
                                final ingredientId = await DatabaseHelper
                                    .instance
                                    .getIngredientIdByName(item.name);

                                // 消費対象になる一番古い在庫を取得する
                                final oldestFood = await DatabaseHelper.instance
                                    .getOldestFoodRecord(ingredientId!);

                                // 消費日は今日
                                final today = DateTime.now().toString().split(
                                  ' ',
                                )[0];

                                // 賞味期限は、消費対象の在庫の賞味期限を使う
                                final expireDate = oldestFood != null
                                    ? oldestFood['expire_date'].toString()
                                    : today;

                                await DatabaseHelper.instance.insertFood(
                                  ingredientId: ingredientId,
                                  quantity: -1,
                                  unit: '個',
                                  purchaseDate: today, // 消費日として表示される日付
                                  expireDate: expireDate, // 元の在庫の賞味期限
                                );

                                widget.onChanged();
                              }
                            },
                          ),
                        ),

                        // 数量表示。ここは通常時も編集時も表示
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ＋ボタンの場所は常に確保。通常時は見えない
                        Visibility(
                          visible: widget.isEditMode,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () async {
                              setState(() {
                                item.quantity++;
                              });

                              final ingredientId = await DatabaseHelper.instance
                                  .getIngredientIdByName(item.name);

                              await DatabaseHelper.instance.insertFood(
                                ingredientId: ingredientId!,
                                quantity: 1,
                                unit: '個',
                                purchaseDate: DateTime.now().toString().split(
                                  ' ',
                                )[0],
                                expireDate: DateTime.now()
                                    .add(const Duration(days: 7))
                                    .toString()
                                    .split(' ')[0],
                              );

                              widget.onChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

        Divider(color: Colors.grey[600], height: 1, thickness: 1),
      ],
    );
  }
}
