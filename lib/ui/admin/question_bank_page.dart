import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/ui/admin/edit_question.dart';

class QuestionBank extends StatefulWidget {
  const QuestionBank({
    required this.questions,
    required this.questionCallback,
    required this.loadMoreCallback,
    super.key,
  });

  final List<Question> questions;
  final void Function(Question, int?) questionCallback;
  final void Function() loadMoreCallback;

  @override
  State<QuestionBank> createState() => _QuestionBankState();
}

class _QuestionBankState extends State<QuestionBank> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    initScrollListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Questions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child:
                          Text('(Level 1 for easy & Level 4 for difficulty)'),
                    ),
                  ],
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
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
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
            question: index == null ? null : widget.questions[index],
            onSubmitCallback: (_) => widget.questionCallback(_, index),
          ),
        );
      },
    );
  }

  void initScrollListener() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        widget.loadMoreCallback();
      }
    });
  }
}
