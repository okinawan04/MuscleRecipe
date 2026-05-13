/// 身体部位の列挙型
enum BodyPart {
  chest('胸'),
  back('背中'),
  shoulder('肩'),
  leg('脚'),
  arm('腕'),
  glute('お尻'),
  abs('腹筋');

  final String displayName;
  const BodyPart(this.displayName);
}

/// トレーニング種目モデル（training_menus テーブル）
class Exercise {
  final int? id; // database id (NULL = 未保存)
  final String name;
  final BodyPart bodyPart;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Exercise({
    this.id,
    required this.name,
    required this.bodyPart,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Exercise copyWith({
    int? id,
    String? name,
    BodyPart? bodyPart,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyPart: bodyPart ?? this.bodyPart,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  // training_models.dart 内の Exercise クラス
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      // categoryの文字列からBodyPartのenumに変換する処理（displayNameを元にする場合）
      bodyPart: BodyPart.values.firstWhere(
        (e) => e.displayName == map['category'],
        orElse: () => BodyPart.chest,
      ),
      name: map['name'],
      // createdAt が必要なら map['created_at'] から変換
    );
  }
}

/// トレーニングセット情報モデル
class TrainingSet {
  final int setNumber;
  final int reps; // 回数
  final double weight; // 重量（kg）
  final double? rm; // 推定1RM

  TrainingSet({
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.rm,
  });

  TrainingSet copyWith({
    int? setNumber,
    int? reps,
    double? weight,
    double? rm,
  }) {
    return TrainingSet(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rm: rm ?? this.rm,
    );
  }
}

/// トレーニング記録モデル（training_records テーブル）
class TrainingRecord {
  final int? id; // database id (NULL = 未保存)
  final int menuId; // training_menus.id への外部キー
  final DateTime trainingDate;
  final int setNumber;
  final double weight;
  final int reps;
  final int? restSeconds;
  final bool isCompleted;
  final String? memo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TrainingRecord({
    this.id,
    required this.menuId,
    required this.trainingDate,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.restSeconds,
    this.isCompleted = false,
    this.memo,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TrainingRecord copyWith({
    int? id,
    int? menuId,
    DateTime? trainingDate,
    int? setNumber,
    double? weight,
    int? reps,
    int? restSeconds,
    bool? isCompleted,
    String? memo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingRecord(
      id: id ?? this.id,
      menuId: menuId ?? this.menuId,
      trainingDate: trainingDate ?? this.trainingDate,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// トレーニングメニュー（UIで使用する一時的なモデル）
class TrainingMenu {
  final String id;
  final Exercise exercise;
  final DateTime date;
  final List<TrainingSet> sets;
  final int restTime; // レストタイマー（秒）

  TrainingMenu({
    required this.id,
    required this.exercise,
    required this.date,
    required this.sets,
    this.restTime = 60,
  });

  // 統計情報を取得
  int get totalSets => sets.length;
  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);
  double get totalWeight => sets.fold(0.0, (sum, set) => sum + set.weight);

  TrainingMenu copyWith({
    String? id,
    Exercise? exercise,
    DateTime? date,
    List<TrainingSet>? sets,
    int? restTime,
  }) {
    return TrainingMenu(
      id: id ?? this.id,
      exercise: exercise ?? this.exercise,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
    );
  }
}

/// 日付ごとのトレーニング記録
class DailyTraining {
  final DateTime date;
  final List<TrainingMenu> menus;

  DailyTraining({
    required this.date,
    required this.menus,
  });

  // 統計情報
  int get totalMenuCount => menus.length;
  int get totalSetCount => menus.fold(0, (sum, menu) => sum + menu.totalSets);
  int get totalRepCount => menus.fold(0, (sum, menu) => sum + menu.totalReps);
  double get totalWeightLoad =>
      menus.fold(0.0, (sum, menu) => sum + menu.totalWeight);
}
