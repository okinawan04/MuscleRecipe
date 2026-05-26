import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'providers/training_data_provider.dart';

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
      onUpgrade: _upgradeDB,
    );
  }

  // データベースのアップグレード処理
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE users ADD COLUMN name TEXT');
    }
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
        name $textType UNIQUE,
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
  

  // 初期種目データをtraining_menusに登録
    await _seedInitialExercises(db);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await instance.database;
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getRecipes() async {
    return await queryAllRows('recipes');
  }

  Future<List<Map<String, dynamic>>> getFoodsWithIngredient() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT f.id,
             f.quantity,
             f.unit,
             f.purchase_date,
             f.expire_date,
             f.memo,
             i.name AS ingredient_name
      FROM foods f
      LEFT JOIN ingredient_master i ON f.ingredient_id = i.id
      ORDER BY f.id DESC
    ''');
  }

  // ユーザー情報の保存（新規作成または更新）
  Future<int> saveUser({
    required String name,
    required double? height,
    required double? weight,
    required int? age,
    required String gender,
    required String trainingPreference,
  }) async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    // 既存ユーザーが存在するか確認
    final existingUsers = await db.query('users', limit: 1);

    if (existingUsers.isEmpty) {
      // 新規ユーザーを作成
      return await db.insert('users', {
        'name': name,
        'height': height,
        'weight': weight,
        'age': age,
        'gender': gender,
        'training_preference': trainingPreference,
        'created_at': now,
        'updated_at': now,
      });
    } else {
      // 既存ユーザーを更新
      return await db.update(
        'users',
        {
          'name': name,
          'height': height,
          'weight': weight,
          'age': age,
          'gender': gender,
          'training_preference': trainingPreference,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [existingUsers.first['id']],
      );
    }
  }

  // ユーザー情報を取得
  Future<Map<String, dynamic>?> getUser() async {
    final db = await instance.database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // ユーザーが存在するか確認
  Future<bool> hasUser() async {
    final user = await getUser();
    return user != null;
  }

  Future<void> ensureDefaultData() async {
    final db = await instance.database;
    final now = DateTime.now().toIso8601String();

    final ingredientCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM ingredient_master'),
        ) ??
        0;
    if (ingredientCount == 0) {
      await db.insert('ingredient_master', {
        'name': '鶏むね肉',
        'base_unit': 'g',
        'calorie': 165,
        'protein': 31.0,
        'fat': 3.6,
        'carbohydrate': 0.0,
        'created_at': now,
        'updated_at': now,
      });
    }

    final foodCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM foods'),
        ) ??
        0;
    if (foodCount == 0) {
      await db.insert('foods', {
        'ingredient_id': 1,
        'quantity': 500,
        'unit': 'g',
        'purchase_date': now,
        'expire_date': now,
        'memo': '冷蔵庫の鶏肉',
        'created_at': now,
        'updated_at': now,
      });
    }

    final recipeCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM recipes'),
        ) ??
        0;
    if (recipeCount == 0) {
      await db.insert('recipes', {
        'name': '鶏むね肉の照り焼き',
        'description': 'ジューシーな鶏むね肉を使った照り焼きです。',
        'steps': '1. 鶏肉を切る\n2. 焼く\n3. タレを絡める',
        'servings': 2,
        'total_calorie': 450,
        'total_protein': 40.0,
        'total_fat': 12.0,
        'total_carbohydrate': 30.0,
        'ingredients_text': '鶏むね肉、醤油、みりん、砂糖',
        'is_ai_generated': 0,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  /// training_menusテーブルに初期種目データを登録
  Future _seedInitialExercises(Database db) async {
    final exercises = TrainingDataProvider.getInitialExercises();
    final now = DateTime.now().toIso8601String();

    for (final exercise in exercises) {
      await db.insert(
        'training_menus',
        {
          'category': exercise.bodyPart.displayName,
          'name': exercise.name,
          'is_active': 1,
          'created_at': now,
          'updated_at': now,
        },
      );
    }
  }

  /// 新しい種目をtraining_menusテーブルに追加（既存の場合は既存IDを返す）
  Future<int> insertExercise({
    required String category,
    required String name,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // 既存の種目があるかチェック
    final existingExercises = await db.query(
      'training_menus',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existingExercises.isNotEmpty) {
      // 既存の種目があれば、そのIDを返す
      return existingExercises.first['id'] as int;
    }

    // 新規作成
    return await db.insert(
      'training_menus',
      {
        'category': category,
        'name': name,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getExercises() async {
  final db = await instance.database;
  // training_menusテーブルから全てのデータを取得
  return await db.query('training_menus');
}

  /// トレーニング記録を training_records テーブルに保存
  Future<int> insertTrainingRecord({
    required int menuId,
    required String trainingDate,
    required int setNumber,
    required double weight,
    required int reps,
    int? restSeconds,
    String? memo,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    return await db.insert(
      'training_records',
      {
        'menu_id': menuId,
        'training_date': trainingDate,
        'set_number': setNumber,
        'weight': weight,
        'reps': reps,
        'rest_seconds': restSeconds ?? 60,
        'is_completed': 0,
        'memo': memo,
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  /// 特定の日付のトレーニング記録を取得
  Future<List<Map<String, dynamic>>> getTrainingRecordsByDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];

    return await db.rawQuery('''
      SELECT 
        tr.id,
        tr.menu_id,
        tr.training_date,
        tr.set_number,
        tr.weight,
        tr.reps,
        tr.rest_seconds,
        tr.is_completed,
        tr.memo,
        tm.name,
        tm.category
      FROM training_records tr
      JOIN training_menus tm ON tr.menu_id = tm.id
      WHERE tr.training_date LIKE ?
      ORDER BY tr.id, tr.set_number
    ''', ['$dateString%']);
  }

  /// 指定期間のトレーニング記録を取得
  Future<List<Map<String, dynamic>>> getTrainingRecordsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startDateString = startDate.toIso8601String().split('T')[0];
    final endDateString = endDate.toIso8601String().split('T')[0];

    return await db.rawQuery('''
      SELECT 
        tr.id,
        tr.menu_id,
        tr.training_date,
        tr.set_number,
        tr.weight,
        tr.reps,
        tr.rest_seconds,
        tr.is_completed,
        tr.memo,
        tm.name,
        tm.category
      FROM training_records tr
      JOIN training_menus tm ON tr.menu_id = tm.id
      WHERE tr.training_date BETWEEN ? AND ?
      ORDER BY tr.training_date, tr.set_number
    ''', [startDateString, endDateString]);
  }

  /// 指定メニュー・日付のトレーニング記録を削除
  Future<int> deleteTrainingRecordsByMenuIdAndDate(
      int menuId, String trainingDate) async {
    final db = await database;
    return await db.delete(
      'training_records',
      where: 'menu_id = ? AND training_date LIKE ?',
      whereArgs: [menuId, '$trainingDate%'],
    );
  }

   /// トレーニング記録を削除
  Future<int> deleteTrainingRecord(int recordId) async {
    final db = await database;
    return await db.delete(
      'training_records',
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}