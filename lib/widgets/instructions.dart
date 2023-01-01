import 'package:flutter/material.dart';
import 'package:screening_test/utils/theme.dart';
import 'package:screening_test/widgets/numbered_bullet_points.dart';

class Instructions extends StatelessWidget {
  const Instructions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      shrinkWrap: true,
      children: const [
        Text('Instructions', style: bold24Dark),
        SizedBox(height: 20),
        NumberedBulletPoint(
          num: 1,
          text: 'Fill out the form & click on start test.',
        ),
        SizedBox(height: 8),
        NumberedBulletPoint(
          num: 2,
          text:
              "A security code will be sent to your given email to verify the email. Enter the code, this will begin a puzzle test which will contain 10 questions. You'll have 15 minutes to complete it. If you enter the wrong security code you'll be taken back to starting screen.",
        ),
        SizedBox(height: 8),
        NumberedBulletPoint(
          num: 3,
          text:
              "Remember you'll not be able to go back to previous question once you skip it.",
        ),
        SizedBox(height: 8),
        NumberedBulletPoint(
          num: 4,
          text:
              "Once you've completed the test you'll be taken to Thank you screen and our HR and hiring manager will receive your test score and the details provided by you.",
        ),
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 20),
        Text('NOTE', style: bold24Dark),
        SizedBox(height: 20),
        NumberedBulletPoint(
          num: 1,
          text: 'Do not try to click outside the browser window.',
        ),
        SizedBox(height: 8),
        NumberedBulletPoint(num: 2, text: 'Do not use keyboard shortcuts.'),
        SizedBox(height: 8),
        NumberedBulletPoint(
          num: 3,
          text:
              'Your test will be automatically submitted if you click outside the browser more than 3 times.',
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
