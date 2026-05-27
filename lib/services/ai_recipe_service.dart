import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../models/recipe.dart';
import '../database_helper.dart';

/// Gemini API を使用してAIレシピを生成するサービス
/// 
/// 責務:
/// - Gemini APIへの接続管理
/// - 在庫データを基にプロンプトを構築
/// - APIレスポンスをパースして Recipe オブジェクトに変換
class AiRecipeService {
  static final AiRecipeService _instance = AiRecipeService._init();

  late final GenerativeModel _model;
  final DatabaseHelper _db = DatabaseHelper.instance;

  AiRecipeService._init() {
    _initializeModel();
  }

  factory AiRecipeService() {
    return _instance;
  }

  /// GenerativeModel を初期化
  /// 
  /// ⚠️ APIキーは .env ファイルの GEMINI_API_KEY から読み込みます
  void _initializeModel() {
    // flutter_dotenv から環境変数を読み込む
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY が .env ファイルに設定されていません。'
        '.env ファイルを確認してください。',
      );
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        maxOutputTokens: 2000,
      ),
    );
  }

  /// 冷蔵庫の在庫から「作れるレシピ」と「+材料で作れるレシピ」を提案
  /// 
  /// 処理フロー:
  /// 1. DBから現在の在庫を取得
  /// 2. 在庫リストを含むプロンプトを構築
  /// 3. Gemini APIにリクエストを送信
  /// 4. JSONレスポンスをパースして List<Recipe> に変換
  /// 
  /// 引数:
  ///   - userPreferences: ユーザーの好み（タンパク質量の目安など）
  /// 
  /// 戻り値: List<Recipe> - AIが生成したレシピのリスト
  /// 
  /// 例外: ネットワークエラーやAPIエラーが発生した場合は [] を返す
  Future<List<Recipe>> generateRecipesFromInventory({
    String userPreferences = '高タンパク質',
  }) async {
    try {
      print('🤖 Generating recipes from inventory...');

      // ステップ1: DB から在庫データを取得
      final inventoryText = await _db.getInventoryPromptText();
      
      // ステップ2: プロンプトを構築
      final prompt = _buildPrompt(inventoryText, userPreferences);
      
      print('📝 Sending prompt to Gemini API...');
      print('Prompt length: ${prompt.length} chars');

      // ステップ3: Gemini APIにリクエストを送信
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        print('⚠️ Empty response from Gemini API');
        return [];
      }

      print('✅ Received response from API');
      print('Response length: ${response.text!.length} chars');

      // ステップ4: JSONレスポンスをパース
      final recipes = _parseJsonResponse(response.text!);
      
      print('✅ Successfully generated ${recipes.length} recipes');
      return recipes;
    } catch (e) {
      print('❌ Error generating recipes: $e');
      return [];
    }
  }

  /// AIに「あるいは少し材料を足せば作れるレシピ」を提案させる
  /// 
  /// 通常の generateRecipesFromInventory より要求の厳密度を下げ、
  /// 「これぐらい足せば作れそう」という提案を得られます
  Future<List<Recipe>> generateFlexibleRecipes({
    String userPreferences = '高タンパク質',
  }) async {
    try {
      print('🤖 Generating flexible recipes (with +1, 2 items)...');

      final inventoryText = await _db.getInventoryPromptText();
      final prompt = _buildFlexiblePrompt(inventoryText, userPreferences);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return [];
      }

      final recipes = _parseJsonResponse(response.text!);
      print('✅ Generated ${recipes.length} flexible recipes');
      return recipes;
    } catch (e) {
      print('❌ Error generating flexible recipes: $e');
      return [];
    }
  }

  /// プロンプトを構築（完全に作れるレシピ向け）
  String _buildPrompt(String inventoryText, String userPreferences) {
    return '''
あなたは筋トレ向けレシピ提案のプロです。

【ユーザーの冷蔵庫の現在の在庫】
$inventoryText

【リクエスト内容】
上記の在庫を使って、以下の条件を満たすレシピを3〜5個、JSON形式で提案してください：

条件：
1. 在庫に含まれている食材のみを使用（追加購入不要）
2. 調理時間は30分以内
3. ユーザーの好み: $userPreferences
4. 栄養バランスが良い（特にタンパク質を重視）
5. 作り方は3〜5ステップで分かりやすく

【出力形式】
以下のJSON形式で、レシピの配列として出力してください。JSONのみを出力し、説明文は不要です。

[
  {
    "id": "recipe_1",
    "name": "レシピ名",
    "description": "簡潔な説明",
    "calories": 300,
    "protein": 25,
    "carbs": 30,
    "fat": 10,
    "ingredients": ["食材1 100g", "食材2 50g"],
    "instructions": ["手順1", "手順2", "手順3"],
    "imageUrl": "https://example.com/recipe.jpg",
    "cookingTime": 15,
    "difficulty": "簡単",
    "genre": "肉料理"
  }
]

重要: JSONの前後に説明文を含めないでください。JSONのみを出力してください。
''';
  }

  /// プロンプトを構築（柔軟なレシピ向け）
  String _buildFlexiblePrompt(String inventoryText, String userPreferences) {
    return '''
あなたは筋トレ向けレシピ提案のプロです。

【ユーザーの冷蔵庫の現在の在庫】
$inventoryText

【リクエスト内容】
上記の在庫を基に、以下の条件を満たすレシピを3〜5個、JSON形式で提案してください：

条件：
1. 在庫の食材を中心に使用（1〜2個の追加食材はOK）
2. 調理時間は30分以内
3. ユーザーの好み: $userPreferences
4. 栄養バランスが良い（特にタンパク質を重視）
5. 作り方は3〜5ステップで分かりやすく

各レシピには以下の情報を含めてください：
- 必要な追加食材があれば description に記載
- 栄養情報（推定値で OK）

【出力形式】
以下のJSON形式で、レシピの配列として出力してください。JSONのみを出力し、説明文は不要です。

[
  {
    "id": "recipe_1",
    "name": "レシピ名",
    "description": "説明（追加食材がある場合: 「+ニンニク 1片」など）",
    "calories": 320,
    "protein": 28,
    "carbs": 35,
    "fat": 12,
    "ingredients": ["在庫食材1 100g", "追加食材 10g"],
    "instructions": ["手順1", "手順2", "手順3"],
    "imageUrl": "https://example.com/recipe.jpg",
    "cookingTime": 20,
    "difficulty": "普通",
    "genre": "肉料理"
  }
]

重要: JSONの前後に説明文を含めないでください。JSONのみを出力してください。
''';
  }

  /// APIレスポンス（JSON文字列）を List<Recipe> にパース
  /// 
  /// 処理:
  /// 1. JSON文字列をクリーニング（余計な説明文を削除）
  /// 2. JSON配列をデコード
  /// 3. 各オブジェクトを Recipe.fromJson で変換
  /// 
  /// エラーハンドリング:
  /// - JSONデコードエラーの場合はコンソールに出力して [] を返す
  /// - 不正なフォーマットのレシピは無視
  List<Recipe> _parseJsonResponse(String responseText) {
    try {
      // ステップ1: JSON文字列をクリーニング
      // APIが説明文を含める場合があるため、JSON部分のみを抽出
      String jsonString = _extractJsonFromResponse(responseText);

      // ステップ2: JSON配列をデコード
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // ステップ3: Recipe オブジェクトに変換
      final recipes = Recipe.fromJsonList(jsonList);

      print('✅ Parsed ${recipes.length} recipes from API response');
      return recipes;
    } catch (e) {
      print('❌ Error parsing API response: $e');
      print('Response text: $responseText');
      return [];
    }
  }

  /// レスポンステキストから JSON を抽出
  /// 
  /// APIが以下のような形式で返す場合に対応:
  /// "ここはテキスト\n[{...}]\nここもテキスト"
  /// 
  /// JSON配列 [...] の部分のみを抽出します
  String _extractJsonFromResponse(String text) {
    // [ で始まり ] で終わる部分を抽出
    final startIndex = text.indexOf('[');
    final endIndex = text.lastIndexOf(']');

    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      return text.substring(startIndex, endIndex + 1);
    }

    // JSON配列が見つからない場合は、オブジェクト {} を試す
    final objStart = text.indexOf('{');
    final objEnd = text.lastIndexOf('}');
    if (objStart != -1 && objEnd != -1 && objStart < objEnd) {
      // 単一オブジェクトの場合は配列に変換
      final json = text.substring(objStart, objEnd + 1);
      return '[$json]';
    }

    throw FormatException('No valid JSON found in response');
  }
}

/// 使用例:
/// 
/// ```dart
/// final aiService = AiRecipeService();
/// 
/// // 在庫で作れるレシピを生成
/// final recipes = await aiService.generateRecipesFromInventory(
///   userPreferences: '高タンパク質・低炭水化物',
/// );
/// 
/// // 少し材料を足せば作れるレシピを生成
/// final flexibleRecipes = await aiService.generateFlexibleRecipes(
///   userPreferences: '高タンパク質',
/// );
/// ```