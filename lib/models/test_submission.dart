import 'dart:convert';

import 'package:screening_test/models/score.dart';

class TestSubmission {
  final String uid;
  final String userId;
  final Score score;
  final List<String> questionIds;
  final List<String> answers;
  final int createdAt;

  const TestSubmission({
    required this.uid,
    required this.userId,
    required this.score,
    required this.questionIds,
    required this.answers,
    required this.createdAt,
  });

  dynamic toJson() => {
        'uid': uid,
        'userId': userId,
        'score': score.toJson(),
        'questionIds': questionIds,
        'answers': answers,
        'createdAt': createdAt,
      };

  factory TestSubmission.fromJson(Map<String, dynamic> json) {
    return TestSubmission(
      uid: json['uid'],
      userId: json['userId'],
      score: Score.fromJson(json['score']),
      questionIds: json['questionIds'],
      answers: json['answers'],
      createdAt: int.parse(json['createdAt']),
    );
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent(' ').convert(this);
  }
}
