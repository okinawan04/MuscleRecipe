import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // シングルトンパターンの設定
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('muscle_recipe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // テーブル作成の実行
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0: false, 1: true

    // 1. ユーザー情報 (PFC計算の基礎データ)
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        height REAL,
        weight $realType,
        age $intType,
        gender $textType,
        training_preference $textType,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // 2. 食材マスター (栄養素の辞書)
    await db.execute('''
      CREATE TABLE ingredient_master (
        id $idType,
        name $textType,
        base_unit $textType,
        calorie $intType,
        protein $realType,
        fat $realType,
        carbohydrate $realType,
        is_active $boolType DEFAULT 1,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // 3. 冷蔵庫・在庫管理 (食材の所有状況)
    await db.execute('''
      CREATE TABLE foods (
        id $idType,
        ingredient_id $intType,
        quantity $intType,
        unit $textType,
        purchase_date TEXT,
        expire_date TEXT,
        memo TEXT,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (ingredient_id) REFERENCES ingredient_master (id)
      )
    ''');

    // 4. レシピ管理 (AI生成レシピの保存対応)
    await db.execute('''
      CREATE TABLE recipes (
        id $idType,
        name $textType,
        description TEXT,
        steps TEXT,
        servings INTEGER,
        total_calorie INTEGER,
        total_protein REAL,
        total_fat REAL,
        total_carbohydrate REAL,
        ingredients_text TEXT,
        is_ai_generated $boolType DEFAULT 0,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // 5. レシピ使用食材 (レシピとマスターの紐付け)
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id $idType,
        recipe_id $intType,
        ingredient_id $intType,
        quantity $intType,
        unit $textType,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id),
        FOREIGN KEY (ingredient_id) REFERENCES ingredient_master (id)
      )
    ''');

    // 6. トレーニング種目マスター (部位別管理)
    await db.execute('''
      CREATE TABLE training_menus (
        id $idType,
        category $textType,
        name $textType,
        is_active $boolType DEFAULT 1,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // 7. 筋トレ記録 (セットごとの詳細記録)
    await db.execute('''
      CREATE TABLE training_records (
        id $idType,
        menu_id $intType,
        training_date $textType,
        set_number $intType,
        weight $realType,
        reps $intType,
        rest_seconds INTEGER,
        is_completed $boolType DEFAULT 0,
        memo TEXT,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (menu_id) REFERENCES training_menus (id)
      )
    ''');
  }

  // ========================================
  // 在庫データ取得メソッド（新規追加）
  // ========================================

  /// 現在の冷蔵庫在庫を取得
  Future<List<Map<String, dynamic>>> getCurrentInventory() async {
    final db = await database;

    try {
      final results = await db.rawQuery('''
        SELECT
          f.id as food_id,
          im.id as ingredient_id,
          im.name as ingredient_name,
          f.quantity,
          f.unit,
          im.protein,
          im.carbohydrate,
          im.fat,
          im.calorie,
          f.expire_date,
          f.memo
        FROM foods f
        JOIN ingredient_master im ON f.ingredient_id = im.id
        WHERE im.is_active = 1
        ORDER BY f.expire_date ASC
      ''');

      return results;
    } catch (e) {
      print('❌ Error fetching inventory: $e');
      return [];
    }
  }

  /// 在庫データをAIプロンプト用の文字列に変換
  Future<String> getInventoryPromptText() async {
    final inventory = await getCurrentInventory();

    if (inventory.isEmpty) {
      return '冷蔵庫には食材がありません。';
    }

    final buffer = StringBuffer('冷蔵庫の在庫:\n');
    for (final item in inventory) {
      final name = item['ingredient_name'] ?? '不明';
      final quantity = item['quantity'] ?? 0;
      final unit = item['unit'] ?? '';
      final protein = item['protein'] ?? 0.0;
      final expireDate = item['expire_date'] ?? '不明';

      buffer.writeln(
        '- $name ${quantity}${unit} (タンパク質 ${protein}g, 期限: $expireDate)',
      );
    }

    return buffer.toString();
  }

  /// サンプル在庫データをDBに挿入（開発用）
  Future<void> insertSampleInventory() async {
    final db = await database;

    // ingredient_master へのサンプル挿入
    final sampleIngredients = [
      {
        'name': '鶏むね肉',
        'base_unit': 'g',
        'calorie': 165,
        'protein': 31.0,
        'fat': 3.6,
        'carbohydrate': 0.0,
      },
      {
        'name': '卵',
        'base_unit': '個',
        'calorie': 70,
        'protein': 6.3,
        'fat': 5.0,
        'carbohydrate': 0.3,
      },
      {
        'name': 'ブロッコリー',
        'base_unit': 'g',
        'calorie': 34,
        'protein': 3.5,
        'fat': 0.4,
        'carbohydrate': 6.6,
      },
      {
        'name': 'サーモン',
        'base_unit': 'g',
        'calorie': 208,
        'protein': 22.0,
        'fat': 13.0,
        'carbohydrate': 0.0,
      },
      {
        'name': 'ご飯',
        'base_unit': 'g',
        'calorie': 130,
        'protein': 2.5,
        'fat': 0.3,
        'carbohydrate': 28.0,
      },
    ];

    try {
      for (final ingredient in sampleIngredients) {
        final existingCount = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ingredient_master WHERE name = ?',
            [ingredient['name']],
          ),
        ) ?? 0;

        if (existingCount == 0) {
          await db.insert('ingredient_master', {
            ...ingredient,
            'is_active': 1,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }

      // foods テーブルへのサンプル挿入
      final sampleFoods = [
        {'ingredient_name': '鶏むね肉', 'quantity': 500, 'unit': 'g'},
        {'ingredient_name': '卵', 'quantity': 6, 'unit': '個'},
        {'ingredient_name': 'ブロッコリー', 'quantity': 300, 'unit': 'g'},
        {'ingredient_name': 'サーモン', 'quantity': 200, 'unit': 'g'},
      ];

      for (final food in sampleFoods) {
        final ingredientResult = await db.rawQuery(
          'SELECT id FROM ingredient_master WHERE name = ?',
          [food['ingredient_name']],
        );

        if (ingredientResult.isNotEmpty) {
          final ingredientId = ingredientResult[0]['id'];
          final existingCount = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM foods WHERE ingredient_id = ?',
              [ingredientId],
            ),
          ) ?? 0;

          if (existingCount == 0) {
            await db.insert('foods', {
              'ingredient_id': ingredientId,
              'quantity': food['quantity'],
              'unit': food['unit'],
              'expire_date': DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
              'memo': 'サンプルデータ',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      print('✅ Sample inventory inserted successfully');
    } catch (e) {
      print('❌ Error inserting sample inventory: $e');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}