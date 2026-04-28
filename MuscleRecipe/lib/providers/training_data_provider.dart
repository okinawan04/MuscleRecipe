import 'package:uuid/uuid.dart';
import '../models/training_models.dart';

/// トレーニングデータを管理するプロバイダー
class TrainingDataProvider {
  static const _uuid = Uuid();

  /// 初期種目データを取得
  static List<Exercise> getInitialExercises() {
    return [
      // 胸
      Exercise(
        id: _uuid.v4(),
        name: 'ベンチプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'インクラインチェストプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'インクラインプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'インクラインダンベルプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'チェストフライ',
        bodyPart: BodyPart.chest,
      ),
      // 背中
      Exercise(
        id: _uuid.v4(),
        name: 'ラットプルダウン',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'デッドリフト',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'バーベルロウ',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'シーテッドロウ',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ワンハンドロウ',
        bodyPart: BodyPart.back,
      ),
      // 肩
      Exercise(
        id: _uuid.v4(),
        name: 'ショルダープレス',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'サイドレイズ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'フロントレイズ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'リアデルトフライ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'スミスマシンショルダープレス',
        bodyPart: BodyPart.shoulder,
      ),
      // 脚
      Exercise(
        id: _uuid.v4(),
        name: 'スクワット',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'レッグプレス',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'レッグカール',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'レッグエクステンション',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'レッグプレス（スミスマシン）',
        bodyPart: BodyPart.leg,
      ),
      // 腕
      Exercise(
        id: _uuid.v4(),
        name: 'バーベルカール',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ダンベルカール',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'トライセプスプレス',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'トライセプスディップス',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'オーバーヘッドエクステンション',
        bodyPart: BodyPart.arm,
      ),
      // お尻
      Exercise(
        id: _uuid.v4(),
        name: 'ヒップスラスト',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ブルガリアンスクワット',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ルーマニアンデッドリフト',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'レッグプレス（ハイバー）',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ケーブルキックバック',
        bodyPart: BodyPart.glute,
      ),
      // 腹筋
      Exercise(
        id: _uuid.v4(),
        name: 'ケーブルクランチ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'クランチ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ハンギングレッグレイズ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'ディクラインシットアップ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'アブドミナルクランチマシン',
        bodyPart: BodyPart.abs,
      ),
    ];
  }

  /// サンプルの日別トレーニング記録を取得
  static List<DailyTraining> getSampleTrainingData() {
    final today = DateTime.now();
    final exercises = getInitialExercises();

    return [
      // 2026/05/26 のサンプルデータ
      DailyTraining(
        date: DateTime(2026, 5, 26),
        menus: [
          TrainingMenu(
            id: _uuid.v4(),
            exercise: exercises
                .firstWhere((e) => e.name == 'ベンチプレス'),
            date: DateTime(2026, 5, 26),
            sets: [
              TrainingSet(setNumber: 1, reps: 7, weight: 50.0),
              TrainingSet(setNumber: 2, reps: 7, weight: 50.0),
              TrainingSet(setNumber: 3, reps: 7, weight: 50.0),
              TrainingSet(setNumber: 4, reps: 7, weight: 50.0),
            ],
            restTime: 60,
          ),
          TrainingMenu(
            id: _uuid.v4(),
            exercise: exercises
                .firstWhere((e) => e.name == 'インクラインチェストプレス'),
            date: DateTime(2026, 5, 26),
            sets: [
              TrainingSet(setNumber: 1, reps: 2, weight: 70.0),
              TrainingSet(setNumber: 2, reps: 2, weight: 70.0),
            ],
            restTime: 60,
          ),
        ],
      ),
      // 今日のサンプルデータ
      DailyTraining(
        date: today,
        menus: [
          TrainingMenu(
            id: _uuid.v4(),
            exercise: exercises
                .firstWhere((e) => e.name == 'スクワット'),
            date: today,
            sets: [
              TrainingSet(setNumber: 1, reps: 10, weight: 60.0),
              TrainingSet(setNumber: 2, reps: 8, weight: 60.0),
              TrainingSet(setNumber: 3, reps: 6, weight: 60.0),
              TrainingSet(setNumber: 4, reps: 6, weight: 60.0),
            ],
            restTime: 90,
          ),
          TrainingMenu(
            id: _uuid.v4(),
            exercise: exercises
                .firstWhere((e) => e.name == 'レッグプレス'),
            date: today,
            sets: [
              TrainingSet(setNumber: 1, reps: 9, weight: 100.0),
            ],
            restTime: 60,
          ),
        ],
      ),
    ];
  }
}
