import 'package:flutter/material.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({
    Key? key,
    required this.collegeList,
    required this.collegeFilter,
    required this.callback,
  }) : super(key: key);

  final List<String> collegeList;
  final Set<String> collegeFilter;
  final void Function(bool?, int) callback;

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 0.4,
      child: ListView.builder(
        itemCount: widget.collegeList.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
            value: widget.collegeFilter.contains(widget.collegeList[index]),
            title: Text(widget.collegeList[index]),
            onChanged: (bool? isChecked) {
              widget.callback(isChecked, index);
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
