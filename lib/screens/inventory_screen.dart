import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'package:muscle_recipe/database_helper.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<FoodCategory> categories;
  List<Map<String, dynamic>> foods = [];
  bool isEditMode = false;

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
    final vegetables =
        await DatabaseHelper.instance.getIngredientsByCategory('野菜');
    final meats = await DatabaseHelper.instance.getIngredientsByCategory('肉');
    final fishes = await DatabaseHelper.instance.getIngredientsByCategory('魚');
    final dairies =
        await DatabaseHelper.instance.getIngredientsByCategory('乳製品・卵');

    final vegetableItems = await _createFoodItems(vegetables);
    final meatItems = await _createFoodItems(meats);
    final fishItems = await _createFoodItems(fishes);
    final dairyItems = await _createFoodItems(dairies);

    sortItemsByStockAndRegistrationOrder(vegetableItems);
    sortItemsByStockAndRegistrationOrder(meatItems);
    sortItemsByStockAndRegistrationOrder(fishItems);
    sortItemsByStockAndRegistrationOrder(dairyItems);

    if (!mounted) return;

    setState(() {
      categories = [
        FoodCategory(name: '野菜', items: vegetableItems),
        FoodCategory(name: '肉', items: meatItems),
        FoodCategory(name: '魚', items: fishItems),
        FoodCategory(name: '乳製品・卵', items: dairyItems),
      ];
    });
  }

  Future<List<FoodItem>> _createFoodItems(
    List<Map<String, dynamic>> ingredients,
  ) async {
    final List<FoodItem> items = [];

    for (final e in ingredients) {
      final ingredientId = e['id'] as int;

      final quantity = await DatabaseHelper.instance
          .getFoodQuantityByIngredientId(ingredientId);

      final isNearExpire =
          await DatabaseHelper.instance.isNearExpire(ingredientId);

      items.add(
        FoodItem(
          id: ingredientId,
          name: e['name'].toString(),
          quantity: quantity,
          originalQuantity: quantity,
          isNearExpire: isNearExpire,
        ),
      );
    }

    return items;
  }

  Future<void> loadFoods() async {
    final result = await DatabaseHelper.instance.getFoods();

    if (!mounted) return;

    setState(() {
      foods = result;
    });
  }

  void sortItemsByStockAndRegistrationOrder(List<FoodItem> items) {
    items.sort((a, b) {
      final aHasStock = a.quantity > 0;
      final bHasStock = b.quantity > 0;

      if (aHasStock && !bHasStock) {
        return -1;
      }

      if (!aHasStock && bHasStock) {
        return 1;
      }

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

  Future<void> saveEditedQuantities() async {
    final today = DateTime.now().toString().split(' ')[0];

    for (final category in categories) {
      for (final item in category.items) {
        final difference = item.quantity - item.originalQuantity;

        if (difference == 0) {
          continue;
        }

        if (difference > 0) {
          await DatabaseHelper.instance.insertFood(
            ingredientId: item.id,
            quantity: difference,
            unit: '個',
            purchaseDate: today,
            expireDate: DateTime.now()
                .add(const Duration(days: 7))
                .toString()
                .split(' ')[0],
          );
        } else {
          final oldestFood =
              await DatabaseHelper.instance.getOldestFoodRecord(item.id);

          final expireDate =
              oldestFood != null ? oldestFood['expire_date'].toString() : today;

          await DatabaseHelper.instance.insertFood(
            ingredientId: item.id,
            quantity: difference,
            unit: '個',
            purchaseDate: today,
            expireDate: expireDate,
          );
        }

        item.originalQuantity = item.quantity;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4A4A4A),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
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

            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : ListView.builder(
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
                        onTap: () async {
                          await saveEditedQuantities();

                          if (!mounted) return;

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
  int originalQuantity;
  bool isNearExpire;

  FoodItem({
    required this.id,
    required this.name,
    this.quantity = 0,
    int? originalQuantity,
    this.isNearExpire = false,
  }) : originalQuantity = originalQuantity ?? quantity;
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
                      splashColor: Colors.grey.withValues(alpha: 0.25),
                      highlightColor: Colors.grey.withValues(alpha: 0.25),
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
                            color: item.quantity > 0 && item.isNearExpire
                                ? Colors.red
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: item.quantity > 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            decorationColor:
                                item.quantity > 0 && item.isNearExpire
                                    ? Colors.red
                                    : Colors.white,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: widget.isEditMode,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              if (item.quantity > 0) {
                                setState(() {
                                  item.quantity--;
                                });
                                widget.onChanged();
                              }
                            },
                          ),
                        ),

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

                        Visibility(
                          visible: widget.isEditMode,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                item.quantity++;
                              });
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