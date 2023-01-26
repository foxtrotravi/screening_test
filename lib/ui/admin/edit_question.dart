import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:screening_test/models/question.dart';
import 'package:screening_test/utils/utils.dart';

class EditQuestionPage extends StatefulWidget {
  const EditQuestionPage({
    super.key,
    required this.isEdit,
    required this.question,
    required this.onSubmitCallback,
  });

  final Question? question;
  final void Function(Question question) onSubmitCallback;
  final bool isEdit;

  @override
  State<EditQuestionPage> createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  int level = 1;
  String selectedValue = '';
  late bool isCreate;
  final key = GlobalKey<FormState>();

  @override
  void initState() {
    isCreate = widget.question == null;
    questionController.text = widget.question?.text ?? '';
    optionAController.text = widget.question?.answer.optionA ?? '';
    optionBController.text = widget.question?.answer.optionB ?? '';
    optionCController.text = widget.question?.answer.optionC ?? '';
    optionDController.text = widget.question?.answer.optionD ?? '';
    level = widget.question?.level ?? 1;
    selectedValue = widget.question?.correctOption ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: !widget.isEdit,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Question',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(FeatherIcons.x),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: widget.isEdit
                ? TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Question'),
                    ),
                    maxLines: 4,
                    controller: questionController,
                    validator: validator,
                  )
                : Text(widget.question!.text),
          ),
          widget.isEdit
              ? TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Option A'),
                  ),
                  controller: optionAController,
                  validator: validator,
                )
              : _buildListTile('A', widget.question!.answer.optionA),
          widget.isEdit
              ? TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Option B'),
                  ),
                  controller: optionBController,
                  validator: validator,
                )
              : _buildListTile('B', widget.question!.answer.optionB),
          widget.isEdit
              ? TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Option C'),
                  ),
                  controller: optionCController,
                  validator: validator,
                )
              : _buildListTile('C', widget.question!.answer.optionC),
          widget.isEdit
              ? TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Option D'),
                  ),
                  controller: optionDController,
                  validator: validator,
                )
              : _buildListTile('D', widget.question!.answer.optionD),
          const SizedBox(height: 20),
          Visibility(
            visible: widget.isEdit,
            child: const Text('Level'),
          ),
          widget.isEdit
              ? Row(
                  children: [
                    Expanded(
                      child: DropdownButton(
                        value: level,
                        items: [1, 2, 3, 4].map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text('$e'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          debugPrint('val: $val');
                          setState(() {
                            level = val;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : Text('Level: ${widget.question!.level}'),
          const SizedBox(height: 20),
          if (widget.isEdit)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Correct option'),
                const SizedBox(width: 20),
                ...['a', 'b', 'c', 'd'].map(
                  (e) {
                    return Row(
                      children: [
                        Radio(
                            value: e,
                            groupValue: selectedValue,
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() {
                                selectedValue = val;
                              });
                            }),
                        Text(e),
                      ],
                    );
                  },
                ).toList()
              ],
            ),
          const SizedBox(height: 20),
          widget.isEdit
              ? ElevatedButton(
                  onPressed: onSubmit,
                  child: Text(isCreate ? 'Create' : 'Save'),
                )
              : ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
        ],
      ),
    );
  }

  ListTile _buildListTile(String leading, String value) {
    bool isSelected = leading.toLowerCase() == widget.question!.correctOption;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.green[100],
      selectedColor: Colors.black,
      leading: Text('$leading.'),
      trailing: isSelected
          ? const Icon(
              FeatherIcons.checkCircle,
              color: Colors.green,
            )
          : null,
      title: Text(value),
    );
  }

  String? validator(String? value) {
    return value != null && value.isNotEmpty ? null : 'Please enter value';
  }

  void onSubmit() async {
    if (!key.currentState!.validate()) {
      if (selectedValue == '') {
        showToast('Please select correct option');
      }
      return;
    }

    final db = FirebaseFirestore.instance;

    final answer = Answer(
      optionA: optionAController.text,
      optionB: optionBController.text,
      optionC: optionCController.text,
      optionD: optionDController.text,
      isUrlA: false,
      isUrlB: false,
      isUrlC: false,
      isUrlD: false,
    );

    final question = Question(
      text: questionController.text,
      answer: answer,
      correctOption: selectedValue,
      level: level,
    );

    final data = {
      'question': question.toJson(),
    };

    if (isCreate) {
      final docRef = await db.collection('questions').add(data);
      debugPrint('docRef: $docRef');
      await db.collection('questions').doc(docRef.id).update({
        'uid': docRef.id,
      });
      question.uid = docRef.id;
      debugPrint('Updated docRef');
    } else {
      await db.collection('questions').doc(widget.question!.uid).update(data);
    }
    if (mounted) {
      const createSuccess = 'Question created successfully';
      const updateSuccess = 'Question updated successfully';
      showToast(
        isCreate ? createSuccess : updateSuccess,
      );
      widget.onSubmitCallback(question);
      Navigator.of(context).pop();
    }
  }
}
