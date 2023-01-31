import 'package:screening_test/models/collection_user.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/score.dart';
import 'package:screening_test/models/test_submission.dart';

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

  static List<TestSubmissionVM> list({
    required List<TestSubmission> testSubmissions,
    required Map<String, TestSubmission> testSubmissionMap,
    required Map<String, Question> questionsMap,
    required Map<String, CollectionUser> usersMap,
    Set<String>? collegeFilter,
    Set<String>? degreeFilter,
    Set<String>? expFilter,
    Set<String>? statusFilter,
  }) {
    final testSubmissionList = <TestSubmissionVM>[];

    for (var i = 0; i < testSubmissions.length; i++) {
      final o = testSubmissions[i];
      final user = usersMap[o.userId];

      if (user != null) {
        if (collegeFilter != null) {
          final college = user.college?.toUpperCase();
          if (!collegeFilter.contains(college)) {
            continue;
          }
        }

        if (degreeFilter != null) {
          final degree = user.highestDegree?.toUpperCase();
          if (!degreeFilter.contains(degree)) {
            continue;
          }
        }

        if (expFilter != null) {
          final exp = user.yearsOfExperience?.toUpperCase();
          if (!expFilter.contains(exp)) {
            continue;
          }
        }

        if (statusFilter != null) {
          final status = user.workingStatus?.toUpperCase();
          if (!statusFilter.contains(status)) {
            continue;
          }
        }
      }

      testSubmissionList.add(
        TestSubmissionVM(
          user: user,
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
