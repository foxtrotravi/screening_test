import 'dart:convert';

class Score {
  final int level1, level2, level3, level4, level5;

  const Score({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  dynamic toJson() => {
        'level1': level1,
        'level2': level2,
        'level3': level3,
        'level4': level4,
        'level5': level5,
      };

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      level1: json['level1'],
      level2: json['level2'],
      level3: json['level3'],
      level4: json['level4'],
      level5: json['level5'],
    );
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent(' ').convert(this);
  }

  int totalScore() {
    return level1 + level2 + level3 + level4 + level5;
  }
}
