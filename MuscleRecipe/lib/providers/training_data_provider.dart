import '../models/training_models.dart';

/// トレーニングデータを管理するプロバイダー
class TrainingDataProvider {
  /// 初期種目データを取得
  static List<Exercise> getInitialExercises() {
    return [
      // 胸
      Exercise(
        name: 'ベンチプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        name: 'インクラインチェストプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        name: 'インクラインプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        name: 'インクラインダンベルプレス',
        bodyPart: BodyPart.chest,
      ),
      Exercise(
        name: 'チェストフライ',
        bodyPart: BodyPart.chest,
      ),
      // 背中
      Exercise(
        name: 'ラットプルダウン',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        name: 'デッドリフト',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        name: 'バーベルロウ',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        name: 'シーテッドロウ',
        bodyPart: BodyPart.back,
      ),
      Exercise(
        name: 'ワンハンドロウ',
        bodyPart: BodyPart.back,
      ),
      // 肩
      Exercise(
        name: 'ショルダープレス',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        name: 'サイドレイズ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        name: 'フロントレイズ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        name: 'リアデルトフライ',
        bodyPart: BodyPart.shoulder,
      ),
      Exercise(
        name: 'スミスマシンショルダープレス',
        bodyPart: BodyPart.shoulder,
      ),
      // 脚
      Exercise(
        name: 'スクワット',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        name: 'レッグプレス',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        name: 'レッグカール',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        name: 'レッグエクステンション',
        bodyPart: BodyPart.leg,
      ),
      Exercise(
        name: 'レッグプレス（スミスマシン）',
        bodyPart: BodyPart.leg,
      ),
      // 腕
      Exercise(
        name: 'バーベルカール',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        name: 'ダンベルカール',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        name: 'トライセプスプレス',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        name: 'トライセプスディップス',
        bodyPart: BodyPart.arm,
      ),
      Exercise(
        name: 'オーバーヘッドエクステンション',
        bodyPart: BodyPart.arm,
      ),
      // お尻
      Exercise(
        name: 'ヒップスラスト',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        name: 'ブルガリアンスクワット',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        name: 'ルーマニアンデッドリフト',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        name: 'レッグプレス（ハイバー）',
        bodyPart: BodyPart.glute,
      ),
      Exercise(
        name: 'ケーブルキックバック',
        bodyPart: BodyPart.glute,
      ),
      // 腹筋
      Exercise(
        name: 'ケーブルクランチ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        name: 'クランチ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        name: 'ハンギングレッグレイズ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
        name: 'ディクラインシットアップ',
        bodyPart: BodyPart.abs,
      ),
      Exercise(
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
            id: '1',
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
            id: '2',
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
            id: '3',
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
            id: '4',
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
