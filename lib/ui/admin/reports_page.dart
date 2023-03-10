import 'package:flutter/material.dart';
import 'package:screening_test/constants/enums.dart';
import 'package:screening_test/models/collection_user.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/models/test_submission.dart';
import 'package:screening_test/utils/utils.dart';
import 'package:screening_test/view_models/test_submission_vm.dart';
import 'package:screening_test/widgets/filter_widget.dart';
import 'package:url_launcher/link.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    super.key,
    required this.testSubmissions,
    required this.testSubmissionMap,
    required this.questionsMap,
    required this.users,
    required this.usersMap,
  });

  final List<TestSubmission> testSubmissions;
  final Map<String, TestSubmission> testSubmissionMap;
  final Map<String, Question> questionsMap;
  final List<CollectionUser> users;
  final Map<String, CollectionUser> usersMap;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late List<TestSubmissionVM> vmList;

  final collegeSet = <String>{},
      degreeSet = <String>{},
      expSet = <String>{},
      statusSet = <String>{};

  final collegeFilter = <String>{},
      degreeFilter = <String>{},
      expFilter = <String>{},
      statusFilter = <String>{};

  @override
  void initState() {
    vmList = TestSubmissionVM.list(
      testSubmissions: widget.testSubmissions,
      testSubmissionMap: widget.testSubmissionMap,
      questionsMap: widget.questionsMap,
      usersMap: widget.usersMap,
    );
    initFilters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headline5,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  showFilter(
                    title: 'College filter',
                    filter: collegeFilter,
                    optionSet: collegeSet,
                    filterType: FilterType.college,
                  );
                },
                child: const Text('College'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  showFilter(
                    title: 'Degree filter',
                    filter: degreeFilter,
                    optionSet: degreeSet,
                    filterType: FilterType.degree,
                  );
                },
                child: const Text('Degree'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  showFilter(
                    title: 'Experience filter',
                    filter: expFilter,
                    optionSet: expSet,
                    filterType: FilterType.experience,
                  );
                },
                child: const Text('Experience'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  showFilter(
                    title: 'Working status filter',
                    filter: statusFilter,
                    optionSet: statusSet,
                    filterType: FilterType.workingStatus,
                  );
                },
                child: const Text('Working status'),
              ),
            ],
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
                  final totalScore = s.totalScore();

                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text('${user?.name}'),
                              Expanded(
                                child: Text(
                                  '<${user?.email}> ${showTimestamp(vm.createdAt)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Visibility(
                          visible: user?.resume != null,
                          child: Link(
                            uri: Uri.parse(user!.resume!),
                            target: LinkTarget.blank,
                            builder: (BuildContext ctx, FollowLink? openLink) {
                              return TextButton(
                                onPressed: openLink,
                                child: const Text('Resume'),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    subtitle: Text(
                      'College: ${user.college}, Degree: ${user.highestDegree}, Exp: ${user.yearsOfExperience}, Status: ${user.workingStatus}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text('Score: $totalScore'),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void initFilters() {
    for (final user in widget.users) {
      final college = user.college?.toUpperCase();
      final highestDegree = user.highestDegree?.toUpperCase();
      final exp = user.yearsOfExperience?.toUpperCase();
      final status = user.workingStatus?.toUpperCase();

      if (college != null) {
        collegeSet.add(college);
        collegeFilter.add(college);
      }

      if (highestDegree != null) {
        degreeSet.add(highestDegree);
        degreeFilter.add(highestDegree);
      }

      if (exp != null) {
        expSet.add(exp);
        expFilter.add(exp);
      }

      if (status != null) {
        statusSet.add(status);
        statusFilter.add(status);
      }
    }
  }

  void showFilter({
    required String title,
    required Set<String> filter,
    required Set<String> optionSet,
    required FilterType filterType,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final list = optionSet.toList();
        return AlertDialog(
          title: const Text('College filter'),
          content: FilterWidget(
            collegeList: list,
            collegeFilter: filter,
            callback: (bool? isChecked, int index) {
              if (isChecked == null) return;

              if (isChecked) {
                filter.add(list[index]);
              } else {
                filter.remove(list[index]);
              }

              switch (filterType) {
                case FilterType.college:
                  applyFilter(collegeFilter: filter);
                  break;
                case FilterType.experience:
                  applyFilter(expFilter: filter);
                  break;
                case FilterType.degree:
                  applyFilter(degreeFilter: filter);
                  break;
                case FilterType.workingStatus:
                  applyFilter(statusFilter: statusFilter);
                  break;
              }
            },
          ),
        );
      },
    );
  }

  void applyFilter({
    Set<String>? collegeFilter,
    Set<String>? degreeFilter,
    Set<String>? expFilter,
    Set<String>? statusFilter,
  }) {
    vmList = TestSubmissionVM.list(
      questionsMap: widget.questionsMap,
      testSubmissionMap: widget.testSubmissionMap,
      testSubmissions: widget.testSubmissions,
      usersMap: widget.usersMap,
      collegeFilter: collegeFilter,
      degreeFilter: degreeFilter,
      expFilter: expFilter,
      statusFilter: statusFilter,
    );
    setState(() {});
  }
}
