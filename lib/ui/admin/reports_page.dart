import 'package:flutter/material.dart';
import 'package:screening_test/models/collection_user.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/score.dart';
import 'package:screening_test/models/test_submission.dart';
import 'package:screening_test/utils/utils.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    super.key,
    required this.testSubmissions,
    required this.testSubmissionMap,
    required this.questionsMap,
    required this.usersMap,
  });

  final List<TestSubmission> testSubmissions;
  final Map<String, TestSubmission> testSubmissionMap;
  final Map<String, Question> questionsMap;
  final Map<String, CollectionUser> usersMap;

  @override
  Widget build(BuildContext context) {
    final vmList = TestSubmissionVM.list(
      testSubmissions,
      testSubmissionMap,
      questionsMap,
      usersMap,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: vmList.length,
                itemBuilder: ((context, index) {
                  final vm = vmList[index];
                  final user = vm.user;
                  final s = vm.score;
                  final totalScore = s.level1 + s.level2 + s.level3 + s.level4;

                  return ListTile(
                    title: Row(
                      children: [
                        Text('${user?.name}'),
                        Text(
                          '<${user?.email}>',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text('${user?.college}'),
                        const SizedBox(width: 20),
                        Text('${user?.highestDegree}'),
                        const SizedBox(width: 20),
                        Text('${user?.yearsOfExperience}'),
                        const SizedBox(width: 20),
                        Text('${user?.workingStatus}'),
                        const SizedBox(width: 20),
                      ],
                    ),
                    subtitle: Text('Score: $totalScore'),
                    trailing: Text(showTimestamp(vm.createdAt)),
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onTap(int index) {}
}

class TestSubmissionVM {
  final CollectionUser? user;
  final String userId;
  final Score score;
  final List<Question?> questionIds;
  final List<dynamic> answers;
  final int createdAt;

  const TestSubmissionVM({
    required this.user,
    required this.userId,
    required this.score,
    required this.questionIds,
    required this.answers,
    required this.createdAt,
  });

  static List<TestSubmissionVM> list(
    List<TestSubmission> testSubmissions,
    Map<String, TestSubmission> testSubmissionMap,
    Map<String, Question> questionsMap,
    Map<String, CollectionUser> usersMap,
  ) {
    final testSubmissionList = <TestSubmissionVM>[];

    for (var i = 0; i < testSubmissions.length; i++) {
      final o = testSubmissions[i];
      testSubmissionList.add(
        TestSubmissionVM(
          user: usersMap[o.userId],
          userId: o.userId,
          score: o.score,
          questionIds: o.questionIds.map((e) => questionsMap[e]).toList(),
          answers: o.answers,
          createdAt: o.createdAt,
        ),
      );
    }
    return testSubmissionList;
  }
}
