class Question {
  final String text;
  final Answer answer;
  final String correctOption;

  const Question({
    required this.text,
    required this.answer,
    required this.correctOption,
  });

  factory Question.fromJson(dynamic json) {
    return Question(
      text: json['text'],
      answer: Answer.fromJson(json['answer']),
      correctOption: json['correct_option'],
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
      const Question(
        text: 'Lorem ipsum dolor salt ameit',
        answer: Answer(
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
      ),
    );

    questions.add(
      const Question(
        text: 'Lorem ipsum dolor salt ameit 2',
        answer: Answer(
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
      ),
    );
    return questions;
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
      optionA: json['option_a'],
      optionB: json['option_b'],
      optionC: json['option_c'],
      optionD: json['option_d'],
      isUrlA: json['is_url_a'],
      isUrlB: json['is_url_b'],
      isUrlC: json['is_url_c'],
      isUrlD: json['is_url_d'],
    );
  }
}
