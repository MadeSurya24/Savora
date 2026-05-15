class SavingGoalModel {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String? emoji;
  final String? colorHex;

  SavingGoalModel({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.emoji,
    this.colorHex,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get progressPercentage => progress * 100;

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'emoji': emoji,
      'colorHex': colorHex,
    };
  }

  factory SavingGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingGoalModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      emoji: map['emoji'] as String?,
      colorHex: map['colorHex'] as String?,
    );
  }

  SavingGoalModel copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? emoji,
    String? colorHex,
  }) {
    return SavingGoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}