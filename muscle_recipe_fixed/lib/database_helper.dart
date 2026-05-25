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

    return await openDatabase(path, version: 3, onCreate: _createDB);
  }

  // テーブル作成の実行
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL';
    const boolType = 'INTEGER NOT NULL';

    // 1. ユーザー情報
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

    // 2. 食材マスター
    await db.execute('''
      CREATE TABLE ingredient_master (
        id $idType,
        category $textType,
        name $textType,
        base_unit $textType,
        calorie $realType,
        protein $realType,
        fat $realType,
        carbohydrate $realType,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // 3. 冷蔵庫・在庫管理
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

    Future<List<Map<String, dynamic>>> getFoodsByIngredientId(
      int ingredientId,
    ) async {
      final db = await database;

      return await db.query(
        'foods',
        where: 'ingredient_id = ?',
        whereArgs: [ingredientId],
      );
    }

    Future<bool> isNearExpire(int ingredientId) async {
      final db = await database;

      final result = await db.query(
        'foods',
        where: 'ingredient_id = ?',
        whereArgs: [ingredientId],
      );

      if (result.isEmpty) {
        return false;
      }

      for (final food in result) {
        final expireDate = DateTime.parse(food['expire_date'] as String);

        final now = DateTime.now();

        final daysLeft = expireDate.difference(now).inDays;

        if (daysLeft <= 3) {
          return true;
        }
      }

      return false;
    }

    // 4. レシピ管理
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

    // 5. レシピ使用食材
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

    // 6. トレーニング種目マスター
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

    // 7. 筋トレ記録
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

    await db.execute('''
  CREATE TABLE purchase_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingredient_id INTEGER,
    quantity INTEGER,
    purchase_date TEXT,
    expire_date TEXT
  )
''');
  }

  Future<void> insertPurchaseHistory({
    required int ingredientId,
    required int quantity,
    required String purchaseDate,
    required String expireDate,
  }) async {
    final db = await database;

    await db.insert('purchase_history', {
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'purchase_date': purchaseDate,
      'expire_date': expireDate,
    });
  }

  // ★デフォルト食材を追加
  Future<void> insertDefaultIngredients() async {
    final db = await database;

    final ingredients = [
      // 野菜類

      // 根菜・いも類
      {
        'category': '野菜',
        'name': '人参',
        'base_unit': '個',
        'calorie': 37,
        'protein': 0.6,
        'fat': 0.1,
        'carbohydrate': 9.6,
      },
      {
        'category': '野菜',
        'name': '玉ねぎ',
        'base_unit': '個',
        'calorie': 37,
        'protein': 1.0,
        'fat': 0.1,
        'carbohydrate': 8.8,
      },
      {
        'category': '野菜',
        'name': 'じゃがいも',
        'base_unit': '個',
        'calorie': 76,
        'protein': 1.6,
        'fat': 0.1,
        'carbohydrate': 17.6,
      },
      {
        'category': '野菜',
        'name': '大根',
        'base_unit': '本',
        'calorie': 18,
        'protein': 0.5,
        'fat': 0.1,
        'carbohydrate': 4.1,
      },
      {
        'category': '野菜',
        'name': 'れんこん',
        'base_unit': '節',
        'calorie': 66,
        'protein': 1.9,
        'fat': 0.1,
        'carbohydrate': 15.5,
      },
      {
        'category': '野菜',
        'name': 'ごぼう',
        'base_unit': '本',
        'calorie': 58,
        'protein': 1.8,
        'fat': 0.1,
        'carbohydrate': 15.4,
      },

      // 実野菜・果菜類
      {
        'category': '野菜',
        'name': 'かぼちゃ',
        'base_unit': '個',
        'calorie': 78,
        'protein': 1.9,
        'fat': 0.3,
        'carbohydrate': 20.6,
      },
      {
        'category': '野菜',
        'name': 'トマト',
        'base_unit': '個',
        'calorie': 19,
        'protein': 0.7,
        'fat': 0.1,
        'carbohydrate': 4.7,
      },
      {
        'category': '野菜',
        'name': 'きゅうり',
        'base_unit': '本',
        'calorie': 13,
        'protein': 1.0,
        'fat': 0.1,
        'carbohydrate': 3.0,
      },
      {
        'category': '野菜',
        'name': 'ピーマン',
        'base_unit': '個',
        'calorie': 22,
        'protein': 0.9,
        'fat': 0.2,
        'carbohydrate': 5.1,
      },
      {
        'category': '野菜',
        'name': 'なす',
        'base_unit': '本',
        'calorie': 18,
        'protein': 1.1,
        'fat': 0.1,
        'carbohydrate': 5.1,
      },
      {
        'category': '野菜',
        'name': 'ブロッコリー',
        'base_unit': '房',
        'calorie': 33,
        'protein': 4.3,
        'fat': 0.5,
        'carbohydrate': 5.2,
      },
      {
        'category': '野菜',
        'name': 'アスパラガス',
        'base_unit': '本',
        'calorie': 21,
        'protein': 2.6,
        'fat': 0.2,
        'carbohydrate': 3.9,
      },

      // 葉物野菜
      {
        'category': '野菜',
        'name': 'キャベツ',
        'base_unit': '玉',
        'calorie': 23,
        'protein': 1.3,
        'fat': 0.2,
        'carbohydrate': 5.2,
      },
      {
        'category': '野菜',
        'name': '白菜',
        'base_unit': '玉',
        'calorie': 14,
        'protein': 0.8,
        'fat': 0.1,
        'carbohydrate': 3.2,
      },
      {
        'category': '野菜',
        'name': 'レタス',
        'base_unit': '玉',
        'calorie': 12,
        'protein': 0.6,
        'fat': 0.1,
        'carbohydrate': 2.8,
      },
      {
        'category': '野菜',
        'name': 'サニーレタス',
        'base_unit': '株',
        'calorie': 16,
        'protein': 1.2,
        'fat': 0.2,
        'carbohydrate': 3.2,
      },
      {
        'category': '野菜',
        'name': 'リーフレタス',
        'base_unit': '株',
        'calorie': 16,
        'protein': 1.4,
        'fat': 0.1,
        'carbohydrate': 3.3,
      },
      {
        'category': '野菜',
        'name': 'ほうれん草',
        'base_unit': '束',
        'calorie': 20,
        'protein': 2.2,
        'fat': 0.4,
        'carbohydrate': 3.1,
      },
      {
        'category': '野菜',
        'name': '小松菜',
        'base_unit': '束',
        'calorie': 13,
        'protein': 1.5,
        'fat': 0.2,
        'carbohydrate': 2.4,
      },
      {
        'category': '野菜',
        'name': 'チンゲン菜',
        'base_unit': '株',
        'calorie': 9,
        'protein': 0.6,
        'fat': 0.1,
        'carbohydrate': 2.0,
      },
      {
        'category': '野菜',
        'name': '水菜',
        'base_unit': '束',
        'calorie': 23,
        'protein': 2.2,
        'fat': 0.1,
        'carbohydrate': 4.8,
      },
      {
        'category': '野菜',
        'name': '春菊',
        'base_unit': '束',
        'calorie': 20,
        'protein': 2.3,
        'fat': 0.3,
        'carbohydrate': 3.9,
      },
      {
        'category': '野菜',
        'name': 'ニラ',
        'base_unit': '束',
        'calorie': 21,
        'protein': 1.7,
        'fat': 0.3,
        'carbohydrate': 4.0,
      },
      {
        'category': '野菜',
        'name': 'モロヘイヤ',
        'base_unit': '束',
        'calorie': 38,
        'protein': 4.8,
        'fat': 0.5,
        'carbohydrate': 6.3,
      },
      {
        'category': '野菜',
        'name': '豆苗',
        'base_unit': '袋',
        'calorie': 31,
        'protein': 3.8,
        'fat': 0.4,
        'carbohydrate': 4.8,
      },
      {
        'category': '野菜',
        'name': 'かいわれ大根',
        'base_unit': 'パック',
        'calorie': 21,
        'protein': 2.1,
        'fat': 0.5,
        'carbohydrate': 3.3,
      },
      {
        'category': '野菜',
        'name': '菜の花',
        'base_unit': '束',
        'calorie': 33,
        'protein': 4.4,
        'fat': 0.2,
        'carbohydrate': 5.8,
      },

      // 香味野菜
      {
        'category': '野菜',
        'name': '長ねぎ',
        'base_unit': '本',
        'calorie': 35,
        'protein': 1.4,
        'fat': 0.1,
        'carbohydrate': 8.3,
      },
      {
        'category': '野菜',
        'name': '大葉',
        'base_unit': '枚',
        'calorie': 37,
        'protein': 3.9,
        'fat': 0.1,
        'carbohydrate': 7.5,
      },
      {
        'category': '野菜',
        'name': 'もやし',
        'base_unit': '袋',
        'calorie': 14,
        'protein': 1.7,
        'fat': 0.1,
        'carbohydrate': 2.6,
      },

      // きのこ類
      {
        'category': '野菜',
        'name': 'しめじ',
        'base_unit': 'パック',
        'calorie': 18,
        'protein': 2.7,
        'fat': 0.6,
        'carbohydrate': 5.0,
      },
      {
        'category': '野菜',
        'name': 'えのき',
        'base_unit': '袋',
        'calorie': 22,
        'protein': 2.7,
        'fat': 0.2,
        'carbohydrate': 7.6,
      },
      {
        'category': '野菜',
        'name': 'しいたけ',
        'base_unit': '個',
        'calorie': 19,
        'protein': 3.0,
        'fat': 0.4,
        'carbohydrate': 4.9,
      },
      {
        'category': '野菜',
        'name': 'まいたけ',
        'base_unit': 'パック',
        'calorie': 15,
        'protein': 2.0,
        'fat': 0.5,
        'carbohydrate': 4.4,
      },
      {
        'category': '野菜',
        'name': 'エリンギ',
        'base_unit': 'パック',
        'calorie': 19,
        'protein': 2.8,
        'fat': 0.4,
        'carbohydrate': 6.0,
      },
      {
        'category': '野菜',
        'name': 'なめこ',
        'base_unit': '袋',
        'calorie': 15,
        'protein': 1.7,
        'fat': 0.2,
        'carbohydrate': 5.2,
      },
      {
        'category': '野菜',
        'name': 'マッシュルーム',
        'base_unit': '個',
        'calorie': 15,
        'protein': 2.9,
        'fat': 0.3,
        'carbohydrate': 2.1,
      },
      {
        'category': '野菜',
        'name': 'きくらげ',
        'base_unit': '袋',
        'calorie': 13,
        'protein': 0.6,
        'fat': 0.2,
        'carbohydrate': 5.2,
      },
      {
        'category': '野菜',
        'name': 'ひらたけ',
        'base_unit': 'パック',
        'calorie': 20,
        'protein': 3.3,
        'fat': 0.3,
        'carbohydrate': 6.2,
      },
      {
        'category': '野菜',
        'name': '松茸',
        'base_unit': '本',
        'calorie': 23,
        'protein': 2.0,
        'fat': 0.6,
        'carbohydrate': 8.2,
      },
      // 肉類

      // 鶏肉
      {
        'category': '肉',
        'name': '鶏むね肉',
        'base_unit': 'g',
        'calorie': 108,
        'protein': 23.3,
        'fat': 1.9,
        'carbohydrate': 0,
      },
      {
        'category': '肉',
        'name': '鶏もも肉',
        'base_unit': 'g',
        'calorie': 200,
        'protein': 16.6,
        'fat': 14.2,
        'carbohydrate': 0,
      },
      {
        'category': '肉',
        'name': 'ささみ',
        'base_unit': '本',
        'calorie': 98,
        'protein': 23.0,
        'fat': 0.8,
        'carbohydrate': 0,
      },
      {
        'category': '肉',
        'name': '手羽先',
        'base_unit': '本',
        'calorie': 226,
        'protein': 17.4,
        'fat': 16.2,
        'carbohydrate': 0.0,
      },
      {
        'category': '肉',
        'name': '手羽元',
        'base_unit': '本',
        'calorie': 175,
        'protein': 18.2,
        'fat': 10.4,
        'carbohydrate': 0.0,
      },

      // 豚肉
      {
        'category': '肉',
        'name': '豚ロース',
        'base_unit': 'g',
        'calorie': 242,
        'protein': 27.0,
        'fat': 14.0,
        'carbohydrate': 0,
      },
      {
        'category': '肉',
        'name': '豚バラ肉',
        'base_unit': 'g',
        'calorie': 386,
        'protein': 14.2,
        'fat': 34.6,
        'carbohydrate': 0.1,
      },
      {
        'category': '肉',
        'name': '豚こま肉',
        'base_unit': 'g',
        'calorie': 236,
        'protein': 18.5,
        'fat': 17.2,
        'carbohydrate': 0.2,
      },

      // 牛肉
      {
        'category': '肉',
        'name': '牛肩ロース',
        'base_unit': 'g',
        'calorie': 250,
        'protein': 26.0,
        'fat': 15.0,
        'carbohydrate': 0,
      },
      {
        'category': '肉',
        'name': '牛もも肉',
        'base_unit': 'g',
        'calorie': 182,
        'protein': 21.2,
        'fat': 10.7,
        'carbohydrate': 0.3,
      },
      {
        'category': '肉',
        'name': '牛バラ肉',
        'base_unit': 'g',
        'calorie': 371,
        'protein': 14.4,
        'fat': 32.9,
        'carbohydrate': 0.2,
      },
      {
        'category': '肉',
        'name': '牛タン',
        'base_unit': 'g',
        'calorie': 269,
        'protein': 15.2,
        'fat': 21.7,
        'carbohydrate': 0.1,
      },

      // ひき肉
      {
        'category': '肉',
        'name': '鶏ひき肉',
        'base_unit': 'g',
        'calorie': 171,
        'protein': 17.5,
        'fat': 12.0,
        'carbohydrate': 0.0,
      },
      {
        'category': '肉',
        'name': '豚ひき肉',
        'base_unit': 'g',
        'calorie': 221,
        'protein': 18.6,
        'fat': 15.1,
        'carbohydrate': 0.0,
      },
      {
        'category': '肉',
        'name': '牛ひき肉',
        'base_unit': 'g',
        'calorie': 251,
        'protein': 17.1,
        'fat': 21.1,
        'carbohydrate': 0.3,
      },
      {
        'category': '肉',
        'name': '合い挽き肉',
        'base_unit': 'g',
        'calorie': 224,
        'protein': 17.3,
        'fat': 15.7,
        'carbohydrate': 0.3,
      },

      // 内臓・その他
      {
        'category': '肉',
        'name': '砂肝',
        'base_unit': 'g',
        'calorie': 86,
        'protein': 18.3,
        'fat': 1.8,
        'carbohydrate': 0.0,
      },
      {
        'category': '肉',
        'name': 'レバー',
        'base_unit': 'g',
        'calorie': 111,
        'protein': 18.9,
        'fat': 3.1,
        'carbohydrate': 0.6,
      },
      {
        'category': '肉',
        'name': 'ラム肉',
        'base_unit': 'g',
        'calorie': 227,
        'protein': 18.0,
        'fat': 16.0,
        'carbohydrate': 0.1,
      },

      // 加工肉
      {
        'category': '肉',
        'name': 'ベーコン',
        'base_unit': '枚',
        'calorie': 405,
        'protein': 12.9,
        'fat': 39.1,
        'carbohydrate': 0.2,
      },
      {
        'category': '肉',
        'name': 'ウインナー',
        'base_unit': '本',
        'calorie': 321,
        'protein': 11.5,
        'fat': 30.6,
        'carbohydrate': 3.0,
      },
      {
        'category': '肉',
        'name': 'ハム',
        'base_unit': '枚',
        'calorie': 196,
        'protein': 16.5,
        'fat': 14.5,
        'carbohydrate': 1.5,
      },
      {
        'category': '肉',
        'name': 'ローストビーフ',
        'base_unit': 'g',
        'calorie': 196,
        'protein': 21.7,
        'fat': 11.7,
        'carbohydrate': 0.9,
      },
      // 魚類

      // 切り身・定番魚
      {
        'category': '魚',
        'name': '鮭',
        'base_unit': '切れ',
        'calorie': 124,
        'protein': 22.3,
        'fat': 4.1,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'マグロ',
        'base_unit': '切れ',
        'calorie': 125,
        'protein': 26.4,
        'fat': 1.4,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'カツオ',
        'base_unit': '切れ',
        'calorie': 105,
        'protein': 23.6,
        'fat': 0.8,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'ブリ',
        'base_unit': '切れ',
        'calorie': 222,
        'protein': 21.4,
        'fat': 17.6,
        'carbohydrate': 0.3,
      },
      {
        'category': '魚',
        'name': 'タイ',
        'base_unit': '切れ',
        'calorie': 142,
        'protein': 20.6,
        'fat': 5.8,
        'carbohydrate': 0.1,
      },

      // 青魚
      {
        'category': '魚',
        'name': 'サバ',
        'base_unit': '切れ',
        'calorie': 211,
        'protein': 20.6,
        'fat': 16.8,
        'carbohydrate': 0.2,
      },
      {
        'category': '魚',
        'name': 'アジ',
        'base_unit': '尾',
        'calorie': 121,
        'protein': 20.7,
        'fat': 4.5,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'イワシ',
        'base_unit': '尾',
        'calorie': 146,
        'protein': 20.9,
        'fat': 6.5,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'サンマ',
        'base_unit': '尾',
        'calorie': 190,
        'protein': 20.3,
        'fat': 12.0,
        'carbohydrate': 0.1,
      },

      // 白身魚
      {
        'category': '魚',
        'name': 'タラ',
        'base_unit': '切れ',
        'calorie': 82,
        'protein': 18.0,
        'fat': 0.7,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'ヒラメ',
        'base_unit': '切れ',
        'calorie': 91,
        'protein': 19.2,
        'fat': 1.2,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'カレイ',
        'base_unit': '切れ',
        'calorie': 95,
        'protein': 19.6,
        'fat': 1.3,
        'carbohydrate': 0.1,
      },

      // 小魚・魚卵
      {
        'category': '魚',
        'name': 'ししゃも',
        'base_unit': '尾',
        'calorie': 166,
        'protein': 21.0,
        'fat': 8.1,
        'carbohydrate': 0.2,
      },
      {
        'category': '魚',
        'name': 'しらす',
        'base_unit': 'g',
        'calorie': 113,
        'protein': 23.1,
        'fat': 1.6,
        'carbohydrate': 0.2,
      },
      {
        'category': '魚',
        'name': '明太子',
        'base_unit': '本',
        'calorie': 126,
        'protein': 21.0,
        'fat': 3.3,
        'carbohydrate': 3.0,
      },

      // 貝・えび・いか・たこ
      {
        'category': '魚',
        'name': 'エビ',
        'base_unit': '尾',
        'calorie': 82,
        'protein': 18.4,
        'fat': 0.6,
        'carbohydrate': 0.3,
      },
      {
        'category': '魚',
        'name': 'イカ',
        'base_unit': '杯',
        'calorie': 76,
        'protein': 17.9,
        'fat': 0.8,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'たこ',
        'base_unit': 'g',
        'calorie': 76,
        'protein': 16.4,
        'fat': 0.7,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'ホタテ',
        'base_unit': '個',
        'calorie': 72,
        'protein': 13.5,
        'fat': 0.9,
        'carbohydrate': 1.5,
      },
      {
        'category': '魚',
        'name': 'あさり',
        'base_unit': '個',
        'calorie': 30,
        'protein': 6.0,
        'fat': 0.3,
        'carbohydrate': 0.4,
      },
      {
        'category': '魚',
        'name': '牡蠣',
        'base_unit': '個',
        'calorie': 58,
        'protein': 6.9,
        'fat': 2.2,
        'carbohydrate': 4.9,
      },

      // 缶詰・加工系
      {
        'category': '魚',
        'name': 'ツナ缶',
        'base_unit': '缶',
        'calorie': 267,
        'protein': 17.7,
        'fat': 21.7,
        'carbohydrate': 0.1,
      },
      {
        'category': '魚',
        'name': 'サバ缶',
        'base_unit': '缶',
        'calorie': 190,
        'protein': 20.9,
        'fat': 10.7,
        'carbohydrate': 0.2,
      },
      {
        'category': '魚',
        'name': 'イワシ缶',
        'base_unit': '缶',
        'calorie': 146,
        'protein': 20.9,
        'fat': 6.5,
        'carbohydrate': 0.1,
      },
      // 乳製品・卵
      {
        'category': '乳製品・卵',
        'name': '牛乳',
        'base_unit': 'ml',
        'calorie': 61,
        'protein': 3.3,
        'fat': 3.8,
        'carbohydrate': 4.8,
      },
      {
        'category': '乳製品・卵',
        'name': 'ヨーグルト',
        'base_unit': 'g',
        'calorie': 56,
        'protein': 3.6,
        'fat': 3.0,
        'carbohydrate': 4.9,
      },
      {
        'category': '乳製品・卵',
        'name': 'チーズ',
        'base_unit': 'g',
        'calorie': 313,
        'protein': 22.7,
        'fat': 26.0,
        'carbohydrate': 1.3,
      },
      {
        'category': '乳製品・卵',
        'name': 'バター',
        'base_unit': 'g',
        'calorie': 745,
        'protein': 0.6,
        'fat': 81.0,
        'carbohydrate': 0.2,
      },
      {
        'category': '乳製品・卵',
        'name': '生クリーム',
        'base_unit': 'ml',
        'calorie': 433,
        'protein': 2.0,
        'fat': 45.0,
        'carbohydrate': 3.1,
      },
      {
        'category': '乳製品・卵',
        'name': '卵',
        'base_unit': '個',
        'calorie': 142,
        'protein': 12.2,
        'fat': 10.2,
        'carbohydrate': 0.4,
      },
      {
        'category': '乳製品・卵',
        'name': '豆腐',
        'base_unit': '丁',
        'calorie': 56,
        'protein': 5.3,
        'fat': 3.5,
        'carbohydrate': 2.0,
      },
      {
        'category': '乳製品・卵',
        'name': '納豆',
        'base_unit': 'パック',
        'calorie': 190,
        'protein': 16.5,
        'fat': 10.0,
        'carbohydrate': 12.1,
      },
    ];

    for (final ingredient in ingredients) {
      final existing = await db.query(
        'ingredient_master',
        where: 'name = ?',
        whereArgs: [ingredient['name']],
      );

      if (existing.isEmpty) {
        await db.insert('ingredient_master', {
          ...ingredient,
          'created_at': DateTime.now().toString(),
          'updated_at': DateTime.now().toString(),
        });
      }
    }
  }

  // カテゴリーごとに食材一覧を取得
  Future<List<Map<String, dynamic>>> getIngredientsByCategory(
    String category,
  ) async {
    final db = await database;

    return await db.query(
      'ingredient_master',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'id ASC',
    );
  }

  // 食材名から食材IDを取得
  Future<int?> getIngredientIdByName(String name) async {
    final db = await database;

    final result = await db.query(
      'ingredient_master',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }

    return null;
  }

  // 食材追加
  Future<int> insertFood({
    required int ingredientId,
    required int quantity,
    required String unit,
    required String purchaseDate,
    required String expireDate,
    String memo = '',
  }) async {
    final db = await database;

    return await db.insert('foods', {
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate,
      'expire_date': expireDate,
      'memo': memo,
      'created_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    });
  }

  // 食材取得
  Future<Map<String, dynamic>?> getFoodByIngredientId(int ingredientId) async {
    final db = await database;

    final result = await db.query(
      'foods',
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // 残っている在庫の中で、賞味期限が一番古いものを取得
  Future<Map<String, dynamic>?> getOldestFoodRecord(int ingredientId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT
      expire_date,
      SUM(quantity) as remaining_quantity
    FROM foods
    WHERE ingredient_id = ?
    GROUP BY expire_date
    HAVING SUM(quantity) > 0
    ORDER BY date(expire_date) ASC
    LIMIT 1
  ''',
      [ingredientId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // 数量更新
  Future<int> updateFoodQuantity({
    required int ingredientId,
    required int quantity,
  }) async {
    final db = await database;

    return await db.update(
      'foods',
      {'quantity': quantity, 'updated_at': DateTime.now().toString()},
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
    );
  }

  // 食材IDから数量取得
  Future<int> getFoodQuantityByIngredientId(int ingredientId) async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(quantity) as total FROM foods WHERE ingredient_id = ?',
      [ingredientId],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }

    return 0;
  }

  // 冷蔵庫内の全食材を取得
  Future<List<Map<String, dynamic>>> getFoods() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT
        foods.id,
        foods.quantity,
        foods.unit,
        foods.expire_date,
        ingredient_master.name
      FROM foods
      INNER JOIN ingredient_master
      ON foods.ingredient_id = ingredient_master.id
    ''');
  }

  Future<List<Map<String, dynamic>>> getFoodHistory(int ingredientId) async {
    final db = await database;

    return await db.rawQuery(
      '''
    SELECT
      purchase_date,
      SUM(quantity) as quantity,
      MIN(expire_date) as expire_date
    FROM foods
    WHERE ingredient_id = ?
      AND date(expire_date) > date('now', '-3 days')
    GROUP BY
      purchase_date,
      expire_date,
      CASE
        WHEN quantity >= 0 THEN 'plus'
        ELSE 'minus'
      END
    ORDER BY purchase_date DESC
  ''',
      [ingredientId],
    );
  }

  // 賞味期限が近いか確認
  // 賞味期限が近い、または切れて3日以内か確認
Future<bool> isNearExpire(int ingredientId) async {
  final db = await database;

  final result = await db.rawQuery(
    '''
    SELECT
      expire_date,
      SUM(quantity) as remaining_quantity
    FROM foods
    WHERE ingredient_id = ?
    GROUP BY expire_date
    HAVING SUM(quantity) > 0
      AND date(expire_date) <= date('now', '+3 days')
      AND date(expire_date) >= date('now', '-3 days')
    LIMIT 1
    ''',
    [ingredientId],
  );

  return result.isNotEmpty;
}

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
