import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    categories = [
      FoodCategory(
        name: '野菜',
        items: [
          FoodItem(name: '人参'),
          FoodItem(name: '白菜'),
          FoodItem(name: 'キャベツ'),
          FoodItem(name: 'レタス'),
          FoodItem(name: 'ほうれん草'),
          FoodItem(name: '小松菜'),
          FoodItem(name: 'ブロッコリー'),
          FoodItem(name: 'カリフラワー'),
          FoodItem(name: 'トマト'),
          FoodItem(name: 'きゅうり'),
          FoodItem(name: 'なす'),
          FoodItem(name: 'ピーマン'),
          FoodItem(name: '玉ねぎ'),
          FoodItem(name: 'じゃがいも'),
          FoodItem(name: 'さつまいも'),
          FoodItem(name: '大根'),
          FoodItem(name: 'ごぼう'),
          FoodItem(name: '玉ねぎ'),
          FoodItem(name: 'ネギ'),
          FoodItem(name: 'トマト'),
          FoodItem(name: 'ピーマン'),
          FoodItem(name: 'パプリカ'),
          FoodItem(name: 'ズッキーニ'),
          FoodItem(name: 'アスパラガス'),
          FoodItem(name: 'オクラ'),
          FoodItem(name: 'かぼちゃ'),
          FoodItem(name: 'れんこん'),
          FoodItem(name: 'もやし'),
          FoodItem(name: 'しめじ'),
          FoodItem(name: 'えのき'),
          FoodItem(name: 'しいたけ'),
          FoodItem(name: 'まいたけ'),
          FoodItem(name: 'エリンギ'),
        ],
      ),
      FoodCategory(
        name: '肉',
        items: [
          FoodItem(name: '鶏もも肉'),
          FoodItem(name: '鶏むね肉'),
          FoodItem(name: 'ささみ'),
          FoodItem(name: '豚肉こま切れ'),
          FoodItem(name: '豚肉ロース'),
          FoodItem(name: '豚肉バラ'),
          FoodItem(name: '豚肉ヒレ'),
          FoodItem(name: '豚肉ひき肉'),
          FoodItem(name: '牛肉こま切れ'),
          FoodItem(name: '牛肉ロース'),
          FoodItem(name: '牛肉バラ'),
          FoodItem(name: '牛肉ヒレ'),
          FoodItem(name: '牛肉ひき肉'),
          FoodItem(name: '合いびき肉'),
        ],
      ),
      FoodCategory(
        name: '魚',
        items: [
          FoodItem(name: '鮭'),
          FoodItem(name: 'さば'),
          FoodItem(name: 'さんま'),
          FoodItem(name: 'あじ'),
          FoodItem(name: 'ほっけ'),
          FoodItem(name: 'さわら'),
          FoodItem(name: 'ぶり'),
          FoodItem(name: 'カレイ'),
          FoodItem(name: 'たら'),
          FoodItem(name: 'えび'),
          FoodItem(name: 'ホタテ'),
          FoodItem(name: 'アサリ'),
          FoodItem(name: 'シジミ'),
          FoodItem(name: 'イカ'),
          FoodItem(name: 'タコ'),

        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF4A4A4A),
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                  Container(
                    margin: const EdgeInsets.only(top: 50),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
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
                    onChanged: () {
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            // OK Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
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
  final String name;
  int quantity;

  FoodItem({required this.name, this.quantity = 0});
}

class FoodCategoryWidget extends StatefulWidget {
  final FoodCategory category;
  final VoidCallback onChanged;

  const FoodCategoryWidget({
    super.key,
    required this.category,
    required this.onChanged,
  }) ;

  @override
  State<FoodCategoryWidget> createState() => _FoodCategoryWidgetState();
}

class _FoodCategoryWidgetState extends State<FoodCategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            widget.category.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            widget.category.isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.white,
          ),
          onTap: () {
            setState(() {
              widget.category.isExpanded = !widget.category.isExpanded;
            });
            widget.onChanged();
          },
        ),
        if (widget.category.isExpanded)
          ...widget.category.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            if (item.quantity > 0) item.quantity--;
                          });
                          widget.onChanged();
                        },
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
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            item.quantity++;
                          });
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          // ★ここから「閉じる」ボタンのコードを書き足します
        if (widget.category.isExpanded)
          InkWell(
            onTap: () {
              setState(() {
                widget.category.isExpanded = false;
              });
              widget.onChanged();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.expand_less, color: Colors.grey, size: 20),
                  SizedBox(width: 4),
                  Text(
                    '閉じる',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        // ★ここまで
        Divider(
          color: Colors.grey[600],
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
