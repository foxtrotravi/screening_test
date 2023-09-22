import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
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
    required this.callback,
  });

  final List<TestSubmission> testSubmissions;
  final Map<String, TestSubmission> testSubmissionMap;
  final Map<String, Question> questionsMap;
  final List<CollectionUser> users;
  final Map<String, CollectionUser> usersMap;
  final void Function() callback;

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

  final _scrollController = ScrollController();

  @override
  void initState() {
    initScrollListener();
    initFilters();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    vmList = TestSubmissionVM.list(
      testSubmissions: widget.testSubmissions,
      testSubmissionMap: widget.testSubmissionMap,
      questionsMap: widget.questionsMap,
      usersMap: widget.usersMap,
      collegeFilter: collegeFilter,
      degreeFilter: degreeFilter,
      expFilter: expFilter,
      statusFilter: statusFilter,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineSmall,
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
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {
                  try {
                    if (kIsWeb) {
                      downloadReport();
                    } else {
                      showToast('This feature is only available for web');
                    }
                  } catch (e) {
                    showToast(e.toString());
                  }
                },
                child: const Text('Download Report'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              child: ListView.builder(
                controller: _scrollController,
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
                            uri: Uri.parse('${user?.resume}'),
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
                      'College: ${user?.college}, Degree: ${user?.highestDegree}, Exp: ${user?.yearsOfExperience}, Status: ${user?.workingStatus}',
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
    debugPrint('Filter applied');
    setState(() {});
  }

  void initScrollListener() {
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        widget.callback();
      }
    });
  }

  Future<void> downloadReport() async {
    final db = FirebaseFirestore.instance;
    final testSubmission = await db.collection('testSubmission').get();
    final users = await db.collection('users').get();

    final usersMap = <String, CollectionUser>{};

    for (final doc in users.docs) {
      final data = doc.data();
      usersMap[data['uid']] = CollectionUser.fromJson(data);
    }

    final header = [
      'Name',
      'Email',
      'Phone number',
      'College',
      'Degree',
      'Working Status',
      'Experience',
      'Resume link',
      'Score',
      'Test id'
    ];

    final list = <List>[];
    list.add(header);

    final docs = testSubmission.docs;
    for (int i = 0; i < docs.length; i++) {
      final doc = docs[i];
      final data = doc.data();

      final user = usersMap[data['userId']];
      final name = user?.name;
      final email = user?.email;
      final phoneNumber = user?.phoneNumber;
      final college = user?.college;
      final degree = user?.highestDegree;
      final workingStatus = user?.workingStatus;
      final experience = user?.yearsOfExperience;
      final resume = user?.resume;

      final scoreMap = data['score'];
      final score = scoreMap['level1'] +
          scoreMap['level2'] +
          scoreMap['level3'] +
          scoreMap['level4'];

      final temp = [
        name,
        email,
        phoneNumber,
        college,
        degree,
        workingStatus,
        experience,
        resume,
        score,
        data['uid'],
      ];
      list.add(temp);
    }

    String csv = const ListToCsvConverter().convert(list);
    debugPrint(csv);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'reports.csv';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }
}
