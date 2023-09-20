import 'dart:convert';

class Question {
  String? uid;
  final String text;
  final String? imageUrl;
  final Answer answer;
  final String correctOption;
  final int level;

  Question({
    this.uid,
    required this.text,
    required this.answer,
    required this.correctOption,
    required this.level,
    this.imageUrl,
  });

  factory Question.fromJson(dynamic json) {
    return Question(
      uid: json['uid'],
      imageUrl: json['question']['imageUrl'],
      text: json['question']['text'],
      answer: Answer.fromJson(json['question']['answer']),
      correctOption: json['question']['correctOption'],
      level: json['question']['level'],
    );
  }

  static List<Question> fromJsonList(dynamic jsonList) {
    final questions = <Question>[];

    for (final json in jsonList) {
      questions.add(Question.fromJson(json));
    }

    return questions;
  }

  static Future<List<Question>> dummyData() async {
    await Future.delayed(const Duration(seconds: 2));
    final questions = <Question>[];

    questions.add(
      Question(
        text: 'Lorem ipsum dolor salt ameit',
        answer: const Answer(
          optionA: 'Some A',
          optionB: 'Some B',
          optionC: 'Some C',
          optionD: 'Some D',
          isUrlA: false,
          isUrlB: false,
          isUrlC: false,
          isUrlD: false,
        ),
        correctOption: 'a',
        level: 1,
      ),
    );

    questions.add(
      Question(
        text: 'Lorem ipsum dolor salt ameit 2',
        answer: const Answer(
          optionA: 'Some A',
          optionB: 'Some B',
          optionC: 'Some C',
          optionD: 'Some D',
          isUrlA: false,
          isUrlB: false,
          isUrlC: false,
          isUrlD: false,
        ),
        correctOption: 'a',
        level: 2,
      ),
    );
    return questions;
  }

  dynamic toJson() => {
        'uid': uid,
        'text': text,
        'imageUrl': imageUrl,
        'answer': answer.toJson(),
        'correctOption': correctOption,
        'level': level,
      };

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(this);
  }
}

class Answer {
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final bool isUrlA;
  final bool isUrlB;
  final bool isUrlC;
  final bool isUrlD;

  const Answer({
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.isUrlA,
    required this.isUrlB,
    required this.isUrlC,
    required this.isUrlD,
  });

  factory Answer.fromJson(dynamic json) {
    return Answer(
      optionA: json['optionA'],
      optionB: json['optionB'],
      optionC: json['optionC'],
      optionD: json['optionD'],
      isUrlA: json['isUrlA'],
      isUrlB: json['isUrlB'],
      isUrlC: json['isUrlC'],
      isUrlD: json['isUrlD'],
    );
  }

  dynamic toJson() => {
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'isUrlA': isUrlA,
        'isUrlB': isUrlB,
        'isUrlC': isUrlC,
        'isUrlD': isUrlD,
      };

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(this);
  }
}
