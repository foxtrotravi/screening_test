import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/ui/admin/edit_question.dart';

class QuestionBank extends StatelessWidget {
  const QuestionBank(this.questions, this.questionCallback, {super.key});

  final List<Question> questions;
  final void Function(Question, int?) questionCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Questions',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  openQuestion(context, isEdit: true);
                },
                child: const Text('Add new'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return InkWell(
                    onTap: () {
                      openQuestion(context, index: index);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            child: Text(
                              '${index + 1}. ${q.text}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text('Level ${q.level}'),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            debugPrint('Edit');
                            openQuestion(
                              context,
                              index: index,
                              isEdit: true,
                            );
                          },
                          icon: const Icon(FeatherIcons.edit),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openQuestion(BuildContext context, {int? index, bool isEdit = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          content: EditQuestionPage(
            isEdit: isEdit,
            question: index == null ? null : questions[index],
            onSubmitCallback: (_) => questionCallback(_, index),
          ),
        );
      },
    );
  }
}
