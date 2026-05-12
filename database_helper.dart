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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}