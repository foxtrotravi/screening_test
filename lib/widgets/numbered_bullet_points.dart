import 'package:flutter/material.dart';

class NumberedBulletPoint extends StatelessWidget {
  const NumberedBulletPoint({
    Key? key,
    required this.num,
    required this.text,
    this.maxLines = 20,
  }) : super(key: key);

  final int num;
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$num.'),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
